
use v6;

our $PROGRAM-NAME is export	= 'finderror';
our $ISWIN32 is export = $*DISTRO ~~ /mswin32/;
#our $CACHE-DATA-DIR				= $*HOME.path ~ '/.config/' ~ $PROGRAM-NAME;
#our $ERRNO-FILENAME				= 'errno.ls';
#our $SOCKET-FILENAME			= 'socket.ls';
#our $SYSTEM-FILENAME			= 'system.ls';

sub errnoCachePath() is export {
	$ISWIN32 ??
		$*HOME.path ~ "/" ~ $PROGRAM-NAME ~ '/error.ls' !!
		$*HOME.path ~ '/.config/' ~ $PROGRAM-NAME ~ '/error.ls';
}

sub win32ErrorSystemCachePath() is export {
	$ISWIN32 ??
		$*HOME.path ~ "/" ~ $PROGRAM-NAME ~ '/system.ls' !!
		$*HOME.path ~ '/.config/' ~ $PROGRAM-NAME ~ '/system.ls';
}

sub win32ErrorSocketCachePath() is export {
	$ISWIN32 ??
		$*HOME.path ~ "/" ~ $PROGRAM-NAME ~ '/socket.ls' !!
		$*HOME.path ~ '/.config/' ~ $PROGRAM-NAME ~ '/socket.ls';
}

sub writeCache($path, @datas) {
	my $eh = $path.IO.open(:w);

	for @datas -> $errno {
		$eh.say("errno:{$errno.errno},number:{$errno.number},comment:{$errno.comment}");
	}

	$eh.close();
}


sub getTempFilename() returns Str is export {
	my $filename = $*PID ~ '-' ~ time ~ '-' ~ (rand * 100).floor;

	if $ISWIN32 {
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