#!/usr/bin/env perl6

use v6;
use lib "../";

use Getopt::Kinoko;

class RunComplier {
	has Getopt 		$.getopt;
	has OptionSet	$!optset;
	has 			@!incode;
	has 			$!out-file;
	has 			$!elf-file;

	method run {
		$!optset := $!getopt{$!getopt.current};
		@!incode := $!optset<e>.value;

		self.prepare-code();

		help($!getopt)
			if +@!incode < 1;

		self.print-code
			if $!optset<p>.values.elems > 1;

		self.generate-file;
	}

	method generate-file {
		$!out-file = self.get-file-name;
	}

	method get-file-name {
		my $path = $!optset<o>.has-value ?? $!optset<o>.value ~ '/' !! '/var/';

		$path ~ $*PID ~ '-' ~ time ~ '.' ~ $!getopt.current;
	}

	method print-code {
		note '-' x 50;
		.note for @!incode;
		note '-' x 50;
	}

	method read-from-user {
		@!incode = [];

		my $end := $!optset<end>.value;

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
		self.read-from-user if $!optset<r>.value;
		unless $!optset<r> {
			@!incode.unshift('{');
			@!incode.unshift($!optset<main>.value);
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
	}
);
$opts.push(
	"c|complier = s",
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

#| set default value for c
$opts-c{'include'} = <stdio.h>;
$opts-c.set-noa-callback( -> $noa {
	if $noa ne "c" {
		X::Kinoko::Fail.new().throw;
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
});

# parser command line
my $getopt = Getopt.new().push('c', $opts-c).push('cpp', $opts-cpp);

$getopt.parse;

run-snippet($getopt.current, $getopt);

#| helper function
multi sub run-snippet($str where $str ~~ /c|cpp/, $getopt) {
	RunComplier.new(getopt => $getopt).run;
}

multi sub run-snippet($str, $getopt) {
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
