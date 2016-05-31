#!/usr/bin/env perl6

use Getopt::Kinoko;

state $VERSION = "0.0.1";

# Errno
class Errno {
	has $.errno;
	has $.value;
	has $.comment;
}

# ErrnoFinder
class ErrnoFinder {
	has %!filter;
	has $.path;
	has @!errnos;

	my regex include {
		<.ws> '#' <.ws> 'include' <.ws>
		\< <.ws> $<header> = (.*) <.ws> \> <.ws>
	}

	my regex edefine {
		<.ws> '#' <.ws> 'define' <.ws>
		$<errno> = ('E'\w*) <.ws>
		$<value> = (\d+) <.ws>
		'/*' <.ws> $<comment> = (.*) <.ws> '*/'
	}

	method !filepath($include) {
		if $include ~~ /^\// {
			return $include;
		}
		return $!path ~ '/' ~ $include;
	}

	method find(Str $file, $top = True) {
        return if %!filter{$file}:exists;

        %!filter{$file} = 1;

		my \fio = $file.IO;

		$!path = fio.abspath().IO.dirname if $top && !$!path.defined;

		if fio ~~ :e && fio ~~ :f {
			for fio.lines -> $line {
				if $line ~~ /<include>/ {
					self.find(self!filepath(~$<include><header>), False);
				}
				elsif $line ~~ /<edefine>/ {
					@!errnos.push: Errno.new(
							errno 	=> ~$<edefine><errno>,
							value 	=> +$<edefine><value>,
							comment	=> ~$<edefine><comment>.trim
						);
				}
			}
		}
		else {
			say "errno !! " ~ $file;
		}
	}

	method result() {
		@!errnos;
	}

	method sorted-result() {
		# NYI
	}
}


# create optionset
my $opts = OptionSet.new("h|help=b;v|version=b;?=b;");

$opts.push("l|list=b");
$opts.push("e|errno=b");
$opts.push("c|comment=b");
$opts.push("n|number=b");
$opts.push("r|regex=b");
$opts.push("p|path=s", "/usr/include");
$opts.push(
	"i|errno-include=s",
	"/usr/include/errno.h",
	callback => -> $path {
		my \io = $path.IO;

		if io !~~ :e || io !~~ :f {
			die "$path is not a valid file";
		}
	}
);

# MAIN
# errno [*option] [errno | regex]
my @conds = getopt($opts, :gnu-style);

# help and version
usage(0) 			if $opts<h> || $opts<help>;
version(0) 			if $opts<v> || $opts<version>;
usage(), version()  if $opts<?>;

#| function
sub usage($exit?) {
	say $*PROGRAM-NAME ~ " " ~ $opts.usage;
	exit($exit) if $exit.defined;
}

sub version($exit?) {
	say "version " ~ $VERSION ~ ", create by araraloren.";
	exit($exit) if $exit.defined;
}
