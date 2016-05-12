#!/usr/bin/env perl6

use v6;
use lib "../";

use Getopt::Kinoko;

my OptionSet $opts-c .= new();

$opts-c.push("f|flags 	= a");
$opts-c.push("i|include = a");
$opts-c.push("l|link 	= a");
$opts-c.push("u|using 	= a");
$opts-c.push("end = s");
$opts-c.push("e = a");
$opts-c.push("p = a");
$opts-c.push("I = a");
$opts-c.push("D = a");
$opts-c.push("L = a");
$opts-c.push("r = b");
$opts-c.push("S = b");
$opts-c.push("E = b");
$opts-c.push(
	"o|output = s",
	-> $output {
		die "Invalid directory"
			if $output.IO ~~ :d;
	}
);
$opts-c.push(
	"m|main = s",
	-> $main is rw {
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
$opts-c.push(
	"c|complier = s",
	-> $complier {
		die "$complier: Not support this complier" 
			if $complier !(elem) < gcc clang >;
	}
);


my Getopt $go .= new();

$go.push('c', $opts-c);

my $other = $opts-c.deep-clone;

$go.parse();

for $go.values {
	for $_.values -> $opt {
		say $opt.perl;
	}
}

say $opts-c.WHICH;
say $other.WHICH;

for $other.values -> $opt {
		say $opt.perl;
}

