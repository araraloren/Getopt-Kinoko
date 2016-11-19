#!/usr/bin/env perl6

use v6;
use Getopt::Kinoko;

constant $VERSIONS = "version 0.1.1, create by Loren.";
constant $TEMPFILE = "snippet";
constant $LINUXTMP = '/tmp/';

state $is-win32;

BEGIN {
    $is-win32 =  $*DISTRO ~~ /mswin32/;
}

class Compiler      { ... }
class ProcessTarget { ... }

my Getopt \getopt = &snippet_initGetopt();

&main(getopt.parse, getopt);

sub snippet_initGetopt() {
    my OptionSet $opts .= new();

    $opts.insert-normal("h|help=b;v|version=b;?=b;");
    $opts.insert-radio("S = b;E = b");
    $opts.push-option("f|flags 	    = a");
    $opts.push-option("i|include 	= a");
    $opts.push-option("l|link 		= a");
    $opts.push-option("p|print 	    = b");
    $opts.push-option(" |pp 		= a");
    $opts.push-option(" |end        = s", '@@CODEEND');
    $opts.push-option("t|           = b"); # do not delete temporary .c
    $opts.push-option("e|           = a");
    $opts.push-option("I|           = a");
    $opts.push-option("D|           = a");
    $opts.push-option("L|           = a");
    $opts.push-option("r|           = b");
    $opts.push-option(" |debug      = b");
    $opts.push-option(
        "o|output = s",
        $is-win32 ?? './' !! '/tmp/', # save . for win32
        callback => -> $output is rw {
            die "Invalid directory"
                if $output.IO !~~ :d;
            $output = $output.IO.abspath;
        }
    );
    $opts.push-option(
        "m|main = s",
        'int main(void)',
        callback => -> $main is rw {
            die "$main: Invalid main function header"
                if $main !~~ /
                    ^ <.ws> int \s+ main <.ws>
                    \( <.ws> [
                    void
                    |
                    <.ws>
                    |
                    int \s+ \w+\, <.ws> char <.ws> [
                        \* <.ws> \* <.ws> \w+
                        |
                        \* <.ws> \w+ <.ws> \[ <.ws> \]
                    ]
                    ] <.ws> \) <.ws>
                /;
            $main = $main.trim;
        },
    );
    $opts.push-option(
        "c|compiler = s",
        'gcc',
        callback => -> $Compiler {
            die "$Compiler: Not support this Compiler"
            if $Compiler !(elem) < gcc clang >;
        }
    );
    #= set default value common
    $opts{'flags'} = <Wall Wextra Werror>;

    #= deep clone for cpp
    my $opts-c		= $opts;
    my $opts-cpp 	= $opts.deep-clone;

    #= set default value for c
    $opts-c{'include'} = <stdio.h>;
    $opts-c.insert-front( -> $arg {
        if $arg.value ne "c" || $arg.index != 0 {
            X::Kinoko::Fail.new().throw;
        }
    });
    #= add using option
    $opts-cpp.push-option("u|using 	= a");
    #= set default value for cpp
    $opts-cpp{'include'} = <iostream>;
    $opts-cpp.insert-front( -> $arg {
        if $arg.value ne "cpp" || $arg.index != 0 {
            X::Kinoko::Fail.new().throw;
        }
    });

    Getopt.new().push('c', $opts-c).push('cpp', $opts-cpp);
}

sub main(@args, Getopt \getopt) {
    my ($language, $opts) = (getopt.current, getopt{getopt.current});

    if $language eq "" || $language !(elem) < c cpp > {
        &printHelpMessage(getopt);
        exit 1;
    }
    if $opts{'version'} {
        &printVersion();
        exit(0) unless $opts{'help'} || $opts{'?'};
    }
    if $opts{'help'} || $opts{'?'} {
        &printHelpMessage(getopt);
        exit(0);
    }

    @args.shift;

    &printHelpMessage(getopt)
        unless &runCompiler($language, $opts, @args);
}

sub runCompiler(Str $language where $language ~~ /c|cpp/, OptionSet \opts, @args) {
    ProcessTarget.new(
        optset => opts,
        target => Compiler.new(
            optset      => opts,
            language    => $language,
            args        => @args
        ).compile()
    ).process();
}

sub promptUser(Str \str) {
    $*OUT.say(str);
}

sub warningUser(Str \str) {
    $*ERR.say(str);
}

sub printHelpMessage(Getopt \getopt) {
    my $help = "Usage:\n";
    for getopt.keys -> $key {
        if getopt.current eq $key || getopt.current eq "" {
            $help ~= $*PROGRAM-NAME ~ " $key " ~ getopt{$key}.usage ~ " *\@args\n";
        }
    }
    print $help;
    exit(0);
}

sub printVersion() {
    say $VERSIONS;
}

#`(
    C & CXX Compiler
)
class Compiler {
    has OptionSet   $.optset;
    has             @!incode;
    has             $.target;
    has             @!compile-args;
    has             $.language;

    method compile {
        @!incode = DeepClone.deep-clone($!optset<e>);
        self.genCode();
        self.printCode() if $!optset<p>;
        self.genArgs();
        self.doCompile();
        $!target;
    }

    method doCompile {
        my $compiler = self.getCompiler($!optset<c>, $!language);
        try {
            my $proc = run $compiler, @!compile-args, :in;        # run方法执行shell命令
            note("exec cmd info -> $compiler" ~ @!compile-args.perl)
                if $!optset<debug>;
            for @!incode {
                note("write gcc stdin -> [{$_}]") if $!optset<debug>;
                $proc.in.say($_);
            }
            $proc.in.close();
            CATCH {
                default {
                    note "Catch exception when run $compiler, {@!compile-args}";
                    ...
                }
            }
        }
    }

    method argsFromOV(Str $option, @value) {
        @!compile-args.push($option ~ .Str) for @value;
    }

    method genArgs {
        self.argsFromOV('-',  $!optset<f>)   if $!optset.has-value('flags');
        self.argsFromOV('-I', $!optset<I>)   if $!optset.has-value('I');
        self.argsFromOV('-D', $!optset<D>)   if $!optset.has-value('D');
        self.argsFromOV('-L', $!optset<L>)   if $!optset.has-value('L');
        self.argsFromOV('-l', $!optset<l>)   if $!optset.has-value('l');
        self.genTarget();
    }

    method genTarget() {
        $!target ~= "{$is-win32 ?? '' !! $LINUXTMP }{$TEMPFILE}-{time}";
		if $!optset<S> {
			$!target ~= ".S";
            @!compile-args.push('-S', '-o', $!target);
		}
		elsif $!optset<E> {
			$!target ~= ".i";
			@!compile-args.push('-E', '-o', $!target);
		}
		else {
			@!compile-args.push('-o', $!target);
		}
        @!compile-args.push("-x{$!language}", '-');
	}

    method getCompiler(Str $Compiler, Str $language) {
        given $Compiler {
            when /gcc/ {
                return {c => 'gcc', cpp => 'g++'}{$language};
            }
            when /clang/ {
                return {c => 'clang', cpp => 'clang++'}{$language};
            }
        }
    }

    method printCode {
        promptUser('-' x 50);
        promptUser(.Str) for @!incode;
        promptUser('-' x 50);
    }

    method readFromUser {
        @!incode = [];
        my $end := $!optset<end>;
        say "Please input your code, make sure your code correct.";
        say "Enter " ,  $end ~ " end input.";
        my \stdin = $*IN;
        loop {
            my $code = stdin.get().chomp;

            last if $code ~~ /^ $end $/;

            @!incode.push: $code;
        }
    }

    method incodeFromOV(Str $prefix, Str $postfix, @value) {
        @!incode.unshift($prefix ~ $_ ~ $postfix)
            for @value.reverse;
    }

    method insertMain {
        @!incode.unshift('{');
        @!incode.unshift($!optset<main>);
        @!incode.push: 'return 0;';
        @!incode.push: '}';
    }

    method genCode {
        self.readFromUser() if $!optset<r>;
        self.insertMain()   unless $!optset<r>;
        self.incodeFromOV('using ', '', $!optset<u>)
            if $!optset.has-value('u');
        self.incodeFromOV('#', '', $!optset<pp>)
            if $!optset.has-value('pp');
        self.incodeFromOV('#include <', '>', $!optset<i>)
            if $!optset.has-value('i');
    }
}

class ProcessTarget {
    has OptionSet   $.optset;
    has             $.target;
    has             @.args;

    method process {
        self.chmod;
        note "run target -> " ~ $!target if $!optset<debug>;
        if $!optset<S> || $!optset<E> {
            self.catTarget();
        }
        else {
            self.runTarget();
        }
    }

    method chmod {
        QX("chmod +x {$!target}") unless $is-win32;
    }

    method runTarget {
        promptUser(QX("{( $is-win32 ?? 'start ' !! '' ) ~ $!target} {@!args.join(' ')}"));
    }

    method catTarget {
        promptUser("{$!target}".IO.slurp);
    }
}