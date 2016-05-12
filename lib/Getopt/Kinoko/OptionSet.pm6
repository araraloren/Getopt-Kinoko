
use v6;

use Getopt::Kinoko::Option;
use Getopt::Kinoko::Exception;

class OptionSet does Positional {
    has Option @!options handles < EXISTS-POS keys values >;
    has        &!callback;

    method new(Str $optionset-str = "", &noa-callback?) {
        self.bless(callback => &noa-callback).append($optionset-str);
    }

    submethod BUILD(:@!options, :&!callback) { }

    method has(Str $name, :$long, :$short) {
        for @!options -> $opt {
            return True if $opt.match-name($name, :$long, :$short);
        }
        False
    }

    method get(Str $name, :$long, :$short) {
        for @!options -> $opt {
            return $opt if $opt.match-name($name, :$long, :$short);
        }
        Option;
    }

    method set(Str $name, $value, :&callback, :$long, :$short) {
        for @!options -> $opt {
            if $opt.match-name($name, :$long, :$short) {
                $opt.set-value($value);
                $opt.set-callback(&callback) if ?&callback;
                last;
            }
        }
    }

    #| can modify value
    method AT-POS(::?CLASS::D: $index) is rw {
        my $option := @!options[$index];

        Proxy.new(
            FETCH => method () { $option; },
            STORE => method ($value) {
                $option.set-value($value);
            }
        );
    }

    #| can modify value
    method AT-KEY(::?CLASS::D: $name) is rw {
        my $option = Option;

        for @!options -> $opt {
            if $opt.match-name($name) {
                $option := $opt;
                last;
            }
        }

        Proxy.new(
            FETCH => method () { $option; },
            STORE => method ($value) {
                $option.set-value($value);
            }
        );
    }

    method EXISTS-KEY($name) {
        return self.has($name);
    }

    method is-set-noa() {
        &!callback.defined;
    }

    method process-noa($noa) {
        &!callback($noa);
    }

    method Numeric() {
        return +@!options;
    }

    method check-force-value() {
        for @!options -> $opt {
            if $opt.is-force && !$opt.has-value {
                X::Kinoko.new(msg => ($opt.is-short ?? $opt.short-name !! $opt.long-name) ~
                    ": Option value is required.").throw();
            }
        }
    }

    method generate-method(Str $prefix = "") {
        for @!options -> $opt {
            if $opt.is-long {
                self.^add_method($prefix ~ $opt.long-name, my method { $opt; });
                self.^compose();
            }
            if $opt.is-short {
                self.^add_method($prefix ~ $opt.short-name, my method { $opt; });
                self.^compose();
            }
        }
        self;
    }

    #=[ option-string;option-string;... ]
    method append(Str $optionset-str) {
        return self if $optionset-str.trim.chars == 0;
        @!options.push(create-option($_)) for $optionset-str.split(';', :skip-empty);
        self;
    }

    multi method push(*%option) {
        @!options.push: create-option(|%option);
        self;
    }

    multi method push(Str $option) {
        @!options.push: create-option($option);
        self;
    }

    multi method push(Str $option, &callback) {
        @!options.push: create-option($option, cb => &callback);
        self;
    }

    multi method push(Str $option, &callback, $value) {
        @!options.push: create-option($option, cb => &callback, :$value);
        self;
    }

    #=[
        how to convenient forward parameters ?
    ]
    method push-str(Str :$short, Str :$long, Bool :$force, :&callback, Str :$value) {
        self.add-option(sn => $short, ln => $long, :$force, cb => &callback, :$value, :mt<s>);
    }

    method push-int(Str :$short, Str :$long, Bool :$force, :&callback, Int :$value) {
        self.add-option(sn => $short, ln => $long, :$force, cb => &callback, :$value, :mt<i>);
    }

    method push-arr(Str :$short, Str :$long, Bool :$force, :&callback, :$value) {
        self.add-option(sn => $short, ln => $long, :$force, cb => &callback, :$value, :mt<a>);
    }

    method push-hash(Str :$short, Str :$long, Bool :$force, :&callback, :$value) {
        self.add-option(sn => $short, ln => $long, :$force, cb => &callback, :$value, :mt<h>);
    }

    method push-bool(Str :$short, Str :$long, Bool :$force, :&callback, Bool :$value) {
        self.add-option(sn => $short, ln => $long, :$force, cb => &callback, :$value, :mt<b>);
    }

    method usage() {
        my Str $usage;

        for @!options -> $opt {
            $usage ~= ' [';
            $usage ~= $opt.usage;
            $usage ~= '] ';
        }

        $usage;
    }
}
