
use v6;

our $PROGRAM-NAME	is export	= 'finderror';
our $CACHE-DATA-DIR				= $*HOME.path ~ '/.config/' ~ $PROGRAM-NAME;
our $ERRNO-FILENAME				= 'errno.ls';
our $SOCKET-FILENAME			= 'socket.ls';
our $SYSTEM-FILENAME			= 'system.ls';

sub getTempFilename() returns Str is export {
	my $filename = $*PID ~ '-' ~ time ~ '-' ~ (rand * 100).floor;

	if $*DISTRO ~~ /mswin32/ {
		return "./" ~ $filename;
	}
	else {
		return "/tmp/" ~ $filename;
	}
}

multi sub shellExec(Str $bin, *@args) is export {
	my $proc = run $bin, @args, :out, :err;
	my $output = $proc.out.slurp-rest;
	my $errmsg = $proc.err.slurp-rest;

	return $output ~ "\n" ~ $errmsg;
}

multi sub shellExec(Str $command) is export {
	my $proc = shell $command, :out, :err;
	my $outmsg = $proc.out.slurp-rest;
	my $errmsg = $proc.err.slurp-rest;

	return $outmsg ~ "\n" ~ $errmsg;
}