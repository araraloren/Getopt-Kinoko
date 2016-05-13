#!/usr/bin/env perl6

use v6;
use lib "../";

use Getopt::Kinoko;

my @file-lines;

my OptionSet $optset .= new(
    "w|ignore-white-line=b;print-sum=b;s|sort=b;desc=b;h|help=b",
    callback => &dispatch-dir-file
);

getopt($optset);

usage() if $optset<h>;

#MAIN
{
    my &getcount = -> $fl {
        $fl.[1] + ($optset<w> ?? 0 !! $fl.[2]);
    };

    my @output;

    if @file-lines.elems > 0 {

        @output = @file-lines.map: {
            [$_.[0], &getcount($_)];
        };

        if $optset{'print-sum'} {
            say [+] @output.map: { $_.[1] };
        }
        else {
            if $optset.get("sort", :long).value {
                @output = @output.sort: {
                    $optset<desc> ?? ($^a.[1] < $^b.[1]) !!
                        ($^a.[1] > $^b.[1]);
                };
            }

            for @output -> $fl {
                say $fl.[0] ~ ': ' ~ $fl.[1];
            }
        }
    }
    else {
        usage();
    }
}

#| help function
sub dispatch-dir-file($path) returns Bool {

    line-count($path.Str.IO.open);

    return True;
}

multi sub line-count(IO::Handle $fileh where $fileh ~~ :f) {
    @file-lines.push: [$fileh.path.abspath, 0, 0];

    my \curr := @file-lines[@file-lines.end];

    for $fileh.lines -> $line {
        curr.[$line.chomp.chars == 0 ?? 2 !! 1]++;
    }

    $fileh.close();
}

multi sub line-count(IO::Handle $handle) {
    say $handle.path.abspath ~ ": Can not read file.";

    $handle.cloe();
}

sub usage() {
    say $*PROGRAM-NAME ~ $optset.usage;
    exit(0);
}
