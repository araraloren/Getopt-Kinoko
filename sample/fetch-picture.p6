#!/usr/bin/env perl6

use Getopt::Kinoko;

constant $TIEBA_URI_PREFIX = "http://tieba.baidu.com/p/";
constant $ACFUN_URI_PREFIX = "http://www.acfun.tv/a/";
constant $BAIDU = "baidu";
constant $ACFUN = "acfun";

my OptionSet $opts .= new;

$opts.insert-normal("h|help=b");
$opts.push-option(
    "t|tempfile=s",
    ".page",
    comment => "Temp file name used when wget fetch webpage, default is '.page'."
);
$opts.push-option(
    "tools=s",
    "wget",
    comment => "Which tool use to fetch webpage and picture, default is 'wget'."
);
$opts.push-option(
    "encoding=s",
    "latin1",
    comment => "What encoding use of webpage, default is latin1."
);
$opts.push-option(
    "beg=i",
    1,
    comment => 'The begin page fetched, default is 1.'
);
$opts.push-option(
    "end=i",
    1,
    comment => 'The last page fetched, default is 1'
);
$opts.push-option(
    "type=s",
    $BAIDU,
    callback => -> $type {
        die "Not a valid type, must be one of [{<baidu acfun>}]"
            if $type !(elem) < baidu acfun >;
    },
    comment => 'Current support website is baidu(fetch tieba picture) and acfun.'
);

sub noteMessage(Str \str, Int \count = 0) {
    note("{' ' x count}=> {str}");
}

main(getopt($opts), $opts);

sub main(@pid, OptionSet \opts) {
    if opts{'h'} {
        note "{$*PROGRAM-NAME} {$opts.usage}\n";
        note(.join("") ~ "\n") if .[1].chars > 1 for opts.comment(2);
        exit 0;
    }
    my @uris = do given opts<type> {
        when $BAIDU {
            $TIEBA_URI_PREFIX X~ @pid;
        }
        when $ACFUN {
            $ACFUN_URI_PREFIX X~ @pid;
        }
    };

    my &get-page = -> \uri {
        my $cmd = "";
        given opts{'tools'} {
            when /wget/ {
                $cmd = "wget -O {$opts<t>} {uri} -q";
            }
            default {
                &noteMessage("Not implement!");
                exit 0;
            }
        }
        QX($cmd);
        $opts<t>.IO.open(enc => $opts{'encoding'}).slurp-rest;
    };

    my &get-npage = -> \opts, \content {
        my Int $n = do given opts<type> {
            when $BAIDU {
                if content ~~ /'<span class="red">'(\d+)'</span>'/ {
                    $/[0].Int;
                }
                else {
                    0
                }
            }
            when $ACFUN {
                1;
            }
        };
        $n;
    };

    for @uris -> \uri {
        my ($dir, $content, $npage, $beg, $end, $count);

        $dir        = @pid.shift;
        &noteMessage("Fetch page total count: {uri}");
        $content    = &get-page(uri);
        if $content.chars < 1 {
            &noteMessage( "Failed!", 1);
            next;
        }
        $npage      = &get-npage(opts, $content);
        $beg        = opts<beg> >= 0 ?? opts<beg> !! 1;
        $end        = opts<end> > $npage ?? $npage !! opts<end>;
        $count      = 0;
        &noteMessage( "Fetch page {$beg} - {$end}", 1);

        loop (my $i = $beg; $i <= $end; ++$i) {
            &noteMessage( "Fetch page {$i} content", 2);
            $content = &get-page(
                do given opts<type> {
                    when $BAIDU {
                        "{uri}?pn={$i}"
                    }
                    when $ACFUN {
                        uri
                    }
                }
            );
            if $content.chars < 1 {
                &noteMessage( "Failed!", 2);
                next;
            }
            &noteMessage( "Try parse page {$i} picture urls", 2);
            given opts<type> {
                when $BAIDU {
                    if $content ~~ m:g/\<img \s+
                        class\=\"BDE_Image\" <-[\>]>+?
                        src\=\"(<-[\"]>+)\" \s+
                        / {
                        $dir.IO.mkdir if $dir.IO !~~ :d;
                        &noteMessage( "Get {+@$/} picture url", 2);
                        for @$/ -> \picture {
                            &noteMessage( "Fetch picture {picture.[0]}", 2);
                            QX("wget -O {$dir}/{$count++}.jpg {picture.[0].Str} -q");
                        }
                    }
                    else {
                        &noteMessage( "Parse page {$i} picture urls failed!", 2);
                    }
                }
                when $ACFUN {
                    if $content ~~ m:g/\<img \s+
                        id\=\"bigImg\" \s+
                        src\=\"(<-[\"]>+)\" \s+
                        / {
                        $dir.IO.mkdir if $dir.IO !~~ :d;
                        &noteMessage( "Get {+@$/} picture url", 2);
                        for @$/ -> \picture {
                            &noteMessage( "Fetch picture {picture.[0]}", 2);
                            QX("wget -O {$dir}/{$count++}.jpg {picture.[0].Str} -q");
                        }
                    }
                    else {
                        &noteMessage( "Parse page {$i} picture urls failed!", 2);
                    }
                }
            }
        }
    }
}
