
use v6;

use Getopt::Kinoko::Parser;
use Getopt::Kinoko::Option;
use Getopt::Kinoko::OptionSet;
use Getopt::Kinoko::Exception;

class Getopt does Associative {
    has OptionSet   %!optionsets handles <AT-KEY EXISTS-KEY keys values kv>;
    has             $!current;
    has Bool        $!generate-method;
    has Bool        $!gnu-style;
    has             @!args;

    method new(:$generate-method, :$gnu-style) {
        self.bless(:generate-method(?$generate-method), :gnu-style(?$gnu-style));
    }

    submethod BUILD(:$!generate-method, :$!gnu-style) { }

    #=[
        push { optionset-name => optionset }s
    ]
    multi method push(*%optionset-list) {
        %!optionsets.push: %optionset-list;
        self;
    }

    multi method push(Str $name, OptionSet $optset) {
        %!optionsets.push: $name => $optset;
        self;
    }

    multi method push(Str $name, Str $optset-string, &callback = Block) {
        %!optionsets.push: $name => OptionSet.new($optset-string, &callback);
        self;
    }

    method current() {
        $!current;
    }

    method parse(@!args = @*ARGS, Str :$prefix = "", :&parser = &kinoko-parser) returns Array {
        my @noa;
        my $optset;

        for %!optionsets.keys -> $key {
            try {
                $optset := %!optionsets{$key};

                @noa := $!gnu-style ??
                    &parser(@!args, $optset, True) !! &parser(@!args, $optset);

                $optset.check-force-value();

                $optset.generate-method(:$prefix) if $!generate-method;

                $!current := $key;

                last;

                CATCH {
                    when X::Kinoko::Fail {
                        $!current = "";
                    }
                    default {
                        note .message;
                        ...
                    }
                }
            }
        }

        @noa;
    }

    #| simple usage
    multi method usage(Str $name) {
        return "" unless %!optionsets{$name}:exists;
        return %!optionsets{$name}.usage();
    }

    #| full usage
    multi method usage() {
        my Str $usage = "Usage:\n";

        for %!optionsets.values {
            $usage ~= $*PROGRAM-NAME ~ .usage ~ "\n";
        }
        $usage.chomp;
    }
}

sub getopt(OptionSet \opset, @args = @*ARGS, Str :$prefix = "", :&parser = &kinoko-parser, :$gnu-style, :$generate-method) is export returns Array {
    my @noa;

    @noa := $gnu-style ?? &parser(@args, opset, True) !! &parser(@args, opset);

    opset.check-force-value();

    opset.generate-method($prefix) if $generate-method;

    @noa;
}
