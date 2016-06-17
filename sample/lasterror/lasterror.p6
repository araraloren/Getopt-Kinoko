#!/usr/bin/env perl6

use v6;
use lib './private';

use Errno;
use PubFunc;
use Downloader;
use Getopt::Kinoko;

state $SOCKET-ERROR-uri = 'https://msdn.microsoft.com/en-us/library/windows/desktop/ms740668%28v=vs.85%29.aspx';
state $SYSTEM-ERROR-uri = 'https://msdn.microsoft.com/en-us/library/windows/desktop/ms681382%28v=vs.85%29.aspx';
state $INCLUDE-PATH		= '/usr/include';
state $ERRNO-INCLUDE	= '/usr/include/errno.h';

# initialize OptionSet
my $optset = OptionSet.new();

$optset.insert-normal("h|help=b;v|version=b;r|regex=b;start=i;end=i;");
$optset.insert-multi("socket-error-uri=s;system-error-uri=s;include-path=s;errno-head=s");
$optset.insert-radio("system=b;socket=b;");
$optset.insert-radio("c-errno=b;win32-lasterror=b;");
$optset.insert-radio("e|errno=b;n|number=b;c|comment=b;", :force);
$optset.insert-radio("use-wget=b;use-curl=b;use-lwp=b;command=s");
$optset.insert-all(&main);

# set default uri
$optset.set-value("start", 0);
$optset.set-value("end", 0); # start and end only use for *list*
$optset.set-value("socket-error-uri", $SOCKET-ERROR-uri);
$optset.set-value("system-error-uri", $SYSTEM-ERROR-uri);
$optset.set-value("include-path", $INCLUDE-PATH);
$optset.set-value("errno-head", $ERRNO-INCLUDE);

# call getopt
getopt($optset, :gnu-style);

# MAIN
sub main(Argument @args) {
# @args => [operator { find | list | update }, ... args ...]
# [... args ...] => [hexadecimal decimal string]
	my $operator = +@args > 0 ?? @args.shift !! "";

	# prepare data
	#if ()

	# executable operator
	given $operator {
		when /find/ {

		}
		when /list/ {

		}
		when /update/ {

		}
		default {
			if $optset{'help'} {
				say "Usage:";
				say $PROGRAM-NAME ~ $optset.usage();
				exit 0;
			}
		}
	}
}

# help function
sub find-help() {

}

sub list-help() {

}

sub update-help() {

}

sub version() {

}