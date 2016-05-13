#!/usr/bin/env perl6

use v6;
use lib "../";

use Getopt::Kinoko;

class RunComplier {
	has Getopt 		$.getopt;
	has OptionSet	$!optset;
	has 			$.current;
	has 			@!incode;
	has 			$!out-file;
	has 			$!target;
	has 			$!cmd;

	method run {
		$!optset := $!getopt{$!current};
		@!incode  = DeepClone.deep-clone($!optset<e>);

		help($!getopt)
			if $!optset<h>;

		self.prepare-code();

		help($!getopt)
			if +@!incode < 1;

		self.print-code
			if $!optset<p>.elems > 1;

		self.generate-file;

		self.generate-cmd;

		self.run-cmd;

		if $!optset<S> || $!optset<E> {
			self.cat-target;
		}
		else {
			self.run-target;
		}

		self.clean;
	}

	method run-target {
		try {
			shell 'chmod +x ' ~ $!target;
			shell $!target;
			CATCH {
				default {
					self.clean;
					...
				}
			}
		}
	}

	method cat-target {
		say "$!target".IO.slurp;
	}
	

	method run-cmd {
		try {
			shell $!cmd;
			CATCH {
				default {
					self.clean;
					...
				}
			}
		}
	}

	method clean {
		unless $!optset.get("output").has-value {
			unlink $!out-file;
		}
		unlink $!target;
	}

	method generate-cmd {
		$!cmd = self.get-complier($!optset<c>, $!current) ~ ' ';

		for $!optset<flags> -> $flag {
			$!cmd ~= '-' ~ $flag ~ ' ';
		}

		if $!optset.has-value("I") {
			for $!optset<I> -> $ipath {
				$!cmd ~= '-I' ~ $ipath ~ ' ';
			}
		}

		for $!optset<D> -> $define {
			$!cmd ~= '-D' ~ $define ~ ' ';
		}

		for $!optset<L> -> $linkpath {
			$!cmd ~= '-L' ~ $linkpath ~ ' ';
		}

		for $!optset<l> -> $link {
			$!cmd ~= '-l' ~ $link ~ ' ';
		}

		#note $!cmd;

		$!cmd ~= self.generate-target;
	}

	method generate-target() {
		if $!optset<S> {
			$!target = "{$!out-file}.S";

			return "-S -o $!target " ~ $!out-file; 
		}
		elsif $!optset<E> {
			$!target = "{$!out-file}.i";

			return "-E -o $!target " ~ $!out-file;
		}
		else {
			$!target = "{$!out-file}.elf";

			return "-o $!target " ~ $!out-file;
		}
	}

	method get-complier(Str $complier, Str $language) {
		given $complier {
			when /gcc/ {
				return {c => 'gcc', cpp => 'g++'}{$language};
			}
			when /clang/ {
				return {c => 'clang', cpp => 'clang++'}{$language};
			}
		}
		help($!getopt);
	}

	method generate-file {
		$!out-file = self.get-file-name;

		my $fh = open($!out-file, :w) 
					or die "Can not save code to " ~ $!out-file;

		# generate include
		if $!optset.has-value("include") {
			for $!optset<i> -> $include {
				$fh.put: '#include <' ~ $include ~ '>';
			}
		} 

		# generate pre-processer command
		if $!optset.get("pp").has-value {
			$fh.put: $*OUT.nl-out for ^2;
			for $!optset<pp> -> $pp {
				$fh.put: '#' ~ $pp ~ $*OUT.nl-out;
			}
		}

		# generate using for cpp
		if $!current eq "cpp" {
			$fh.put: $*OUT.nl-out for ^2;
			if $!optset.get("using").has-value {
				for $!optset<u> -> $using {
					$fh.put: 'using ' ~ $using ~ ';';
				}
			}
		}

		# generate code
		$fh.put: $_ for @!incode;

		$fh.close();
	}

	method get-file-name {
		my $path = $!optset.get("o").has-value ?? $!optset<o> ~ '/' !! '/var/';

		$path ~ $*PID ~ '-' ~ time ~ '.' ~ $!current;
	}

	method print-code {
		note '-' x 50;
		.note for @!incode;
		note '-' x 50;
	}

	method read-from-user {
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

	method prepare-code {
		self.read-from-user if $!optset<r>;

		# note @!incode;

		unless ($!optset<r> || +@!incode < 1) {
			@!incode.unshift('{');
			@!incode.unshift($!optset<main>);
			@!incode.push: 'return 0;';
			@!incode.push: '}';
		}
	}
}

# MAIN
my OptionSet $opts .= new();

$opts.push("f|flags 	= a");
$opts.push("i|include 	= a");
$opts.push("l|link 		= a");
$opts.push("h|help		= b");
$opts.push("p|print 	= b");
$opts.push(" |pp 		= a");
$opts.push("end = s", '@@CODEEND');
$opts.push("e = a");
$opts.push("I = a");
$opts.push("D = a");
$opts.push("L = a");
$opts.push("r = b");
$opts.push("S = b");
$opts.push("E = b");
$opts.push(
	"o|output = s",
	callback => -> $output is rw {
		die "Invalid directory"
			if $output.IO ~~ :d;
		$output = $output.IO.abspath;
	}
);
$opts.push(
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
$opts.push(
	"c|complier = s",
	'gcc',
	callback => -> $complier {
		die "$complier: Not support this complier"
			if $complier !(elem) < gcc clang >;
	}
);

#| set default value common
$opts{'flags'} = <Wall Wextra Werror>;

#| deep clone for cpp
my $opts-c		= $opts;
my $opts-cpp 	= $opts.deep-clone;
my $current		= "";

#| set default value for c
$opts-c{'include'} = <stdio.h>;
$opts-c.set-noa-callback( -> $noa {
	if $noa ne "c" {
		X::Kinoko::Fail.new().throw;
	}
	else {
		$current = $noa;
	}
});

#| add using option
$opts-cpp.push("u|using 	= a");
#| set default value for cpp
$opts-cpp{'include'} = <iostream>;
$opts-cpp.set-noa-callback( -> $noa {
	if $noa ne "cpp" {
		X::Kinoko::Fail.new().throw;
	}
	else {
		$current = $noa;
	}
});

# parser command line
my $getopt = Getopt.new().push('c', $opts-c).push('cpp', $opts-cpp);

$getopt.parse;

#note ' ~~ >' ~ $current;

run-snippet($current, $getopt);

#| helper function
multi sub run-snippet(Str $current where $current ~~ /c|cpp/, $getopt) {
	RunComplier.new(:$current, getopt => $getopt).run;
}

multi sub run-snippet($str, $getopt) {
	note " ~~ なにそれ !!";
	help($getopt);
}

sub help($getopt) {
	my $help = "Usage:\n";

	for $getopt.keys -> $key {
		$help ~= $*PROGRAM-NAME ~ " $key " ~ $getopt{$key}.usage ~ "\n";
	}

	print $help;

	exit(0);
}