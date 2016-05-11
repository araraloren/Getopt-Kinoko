
use v6;

use Getopt::Kinoko::OptionSet;
use Getopt::Kinoko::Exception;

multi sub kinoko-parser(@args is copy, OptionSet \optset) is export returns Array {
    my @noa;
    my $opt;
    my Str $optname;
    my $last-is-boolean = False;

    my regex lprefix { '--' }
    my regex sprefix { '-'  }
    my regex optname { .*   { $optname = ~$/; } }

    while +@args > 0 {
        my \arg = @args.shift;

        given arg {
            when /^ [<lprefix> || <sprefix>] <.&optname> / {
                if optset.has($optname, long => $<lprefix>.defined, short => $<sprefix>.defined) {
                    $opt := optset.get($optname, long => $<lprefix>.defined, short => $<sprefix>.defined);
                }
                else {
                    X::Kinoko::Fail.new().throw;
                }
            }
            default {
                if !optset.is-set-noa || !optset.process-noa(arg) {
                    @noa.push: arg;
                }
            }
        }

        if +@args > 0 || $opt.is-boolean {
            $last-is-boolean = $opt.is-boolean;
            $opt.set-value($opt.is-boolean ?? True !! @args.shift);
        }
        else {
            X::Kinoko.new(msg => $optname ~ ": Need a value.").throw;
        }
    }
    @noa;
}

multi sub kinoko-parser(@args is copy, OptionSet \optset, $gnu-style) is export returns Array {
    my @noa;
    my $opt;
    my $optname;
    my $optvalue;
    my $last-is-boolean = True;

    my regex lprefix    { '--' }
    my regex sprefix    { '-'  }
    my regex optname    { <-[\=]>* { $optname = ~$/; } }
    my regex optvalue   { .*   }

    while +@args > 0 {
        my \arg = @args.shift;

        given arg {
            when /^ [<lprefix> || <sprefix>]  <.&optname> \= <optvalue> / {
                if optset.has($optname, long => $<lprefix>.defined, short => $<sprefix>.defined) {
                    $opt := optset.get($optname, long => $<lprefix>.defined, short => $<sprefix>.defined);
                    X::Kinoko.new(msg => $optname ~ ": Need a value.").throw if !$<optvalue>.defined && !$opt.is-boolean;
                    $last-is-boolean = $opt.is-boolean;
                    $opt.set-value($opt.is-boolean ?? True !! $<optvalue>);
                }
                elsif $<sprefix>.defined {
                    @args.unshift: | ( '-' X~ $optname.split("", :skip-empty) );
                }
                else {
                    X::Kinoko::Fail.new().throw;
                }
            }
            when /^ [<lprefix> || <sprefix>] <.&optname> / {
                if optset.has($optname, long => $<lprefix>.defined, short => $<sprefix>.defined) {
                    $opt := optset.get($optname, long => $<lprefix>.defined, short => $<sprefix>.defined);
                    $last-is-boolean = $opt.is-boolean;
                    if +@args > 0 || $opt.is-boolean {
                        $opt.set-value($opt.is-boolean ?? True !! @args.shift);
                    }
                    else {
                        X::Kinoko.new(msg => $optname ~ ": Need a value.").throw;
                    }
                }
                else {
                    X::Kinoko::Fail.new().throw;
                }
            }
            default {
                #W::Kinoko.new("Argument behind boolean option.").warn if $last-is-boolean;

                if !optset.is-set-noa || !optset.process-noa(arg) {
                    @noa.push: arg;
                }
            }
        }
    }
    @noa;
}
