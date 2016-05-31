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
	has $!channel;

	submethod BUILD(:$!channel = Channel.new) { }

	my regex include {
		<.ws> '#' <.ws> 'include' <.ws> 
		\< <.ws> $<header> = (<[\w./]>*) <.ws> \> <.ws>
	}

	my regex edefine {
		<.ws> '#' <.ws> 'define' <.ws> 
		$<errno> = ('E'\w*) <.ws> 
		$<value> = (\d+) <.ws> 
		'/*' <.ws> $<comment> = (.*) <.ws> '*/'
	}

	method !abs-dirname(IO::Path $path) {
		$path.abspath().IO.dirname;
	}

	method !filepath($curfile, $include) {
		if $include ~~ /$\// {
			return $include;
		}
		return self!abs-dirname($curfile) ~ '/' ~ $include;
	}

	method find(Str $file, $top = True) {
		my @promises = [];
        say $file;
		await start {
			my \fio = $file.IO;

			if fio ~~ :e && fio ~~ :f {
				for fio.lines -> $line {
					if $line ~~ /<include>/ {
						push @promises, start {
						    say "process -> ";
						    say $<include>;
						    say $<header>;
							self.find(self!filepath(fio, ~$<include><header>), False);
						};
					}
					elsif $line ~~ /<edefine>/ {
						$!channel.send(
							Errno.new(
								errno 	=> ~$<edefine><errno>,
								value 	=> +$<edefine><value>,
								comment	=> ~$<edefine><comment>
							)
						);
					}
				}
			}
		}

		await Promise.allof(@promises);

		$!channel.close() if $top;
	}

	method traversal(&callback) {
		while True {
			try {
				&callback($!channel.receive());
				CATCH {
					default {
						last;
					}
				}
			}
		}
	}

	method result() {
		my @result = [];

		self.traversal(-> $r { @result.push($r); });

		return @result;
	}
}


# create optionset
my $opts = OptionSet.new("h|help=b;v|version=b;?=b;");

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
getopt($opts, :gnu-style);

# help and version
if $opts<h> || $opts<help> {
	usage();
	exit(0);
}

if $opts<v> || $opts<version> {
	version();
	exit(0);
}

if $opts<?> {
	version();
	usage();
	exit(0);
}

#| function
sub usage() {
	say $*PROGRAM-NAME ~ " " ~ $opts.usage;
}

sub version() {
	say "version " ~ $VERSION ~ ", create by araraloren.";
}
