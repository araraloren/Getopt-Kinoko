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
	my @caches = get-data($optset);

	say @caches;

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

# prepare data
sub get-data(OptionSet \optset) {
	my ($errno, $win32) = (optset{'c-errno'}, optset{'win32-lasterror'});

	if !$errno && !$win32 {
		$errno = $win32 = True;
	}

	my @ret = [];

	if $errno {
		@ret.append: get-errno-data(optset);
	}

	if $win32 {
		@ret.append: get-win32-error-data(optset);
	}

	return @ret;
}

# prepare errno data
sub get-errno-data(OptionSet \optset) {
	my $epath = errnoCachePath();

	if $epath.IO !~~ :e {
		update-errno-data(optset);
	}

	if $epath.IO ~~ :r {
		return Parser.parse(Downloader::Cache.get($epath));	
	}
	else {
		note "Can not read {$epath.path}";
		exit -1;
	}
}

sub update-errno-data(OptionSet \optset) {
	my $ef = ErrnoFinder.new(path => optset{'include-path'});

	$ef.find(optset{'errno-head'});

	writeCache(errnoCachePath(), $ef.result());	
}

# prepare win32 error data
sub get-win32-error-data(OptionSet \optset) {
	my ($need-system, $need-socket) = (optset{'system'}, optset{'socket'});

	if !$need-system && !$need-socket {
		$need-system = $need-socket = True;
	}

	my @rets = [];

	if $need-system {
		my $spath = win32ErrorSystemCachePath();

		if $spath.IO !~~ :e {
			update-win32-error-data(optset, :system);
		}

		if $spath.IO ~~ :r {
			@rets.append: Parser.parse(Downloader::Cache.get($spath));	
		}
	}
	if $need-socket {
		my $spath = win32ErrorSocketCachePath();

		if $spath.IO !~~ :e {
			update-win32-error-data(optset, :socket);
		}

		if $spath.IO ~~ :r {
			@rets.append: Parser.parse(Downloader::Cache.get($spath));	
		}
	}

	return @rets;
}

sub get-downloader(OptionSet \optset) {
	if optset{'use-wget'} {
		return Downloader::Command.new(command => 'wget');
	}
	elsif optset{'use-curl'} {
		return Downloader::Command.new(command => 'curl');
	}
	elseif optset{'use-lwp'} {
		return Downloader::Module.new();
	}
	elsif optset.has-value('command') {
		return Downloader::Command.new(command => optset{'command'});
	}
	else {
		return Downloader.new();
	}
 }

sub update-win32-error-data(OptionSet \optset, :$system, :$socket) {
	if ?$system {
		my @ret = Parser::Win32System.parse(get-downloader().get(optset{'system-error-uri'}));

		writeCache(win32ErrorSystemCachePath(), @ret);
	}
	if $?socket {
		my @ret = Parser::Win32Socket.parse(get-downloader().get(optset{'socket-error-uri'}));

		writeCache(win32ErrorSocketCachePath(), @ret);
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