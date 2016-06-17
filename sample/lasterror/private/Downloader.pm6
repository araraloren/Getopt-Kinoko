
use v6;
use Errno;
use PubFunc;
use RefOptionSet;
use NIException;

role Downloader does RefOptionSet {
	method get(Str $uri, $data) {
		X::NotImplement.new().throw();
	}
}

#| use %URI% represent uri and %FILE% represent file
class Downloader::Command does Downloader {
	state %COMMAND = %(
		wget 	=> 'wget %URI% -o %FILE%',
		curl 	=> 'curl %URI% -o %FILE%',
	);

	method get(Str $uri, $data) {
		my $tf = getTempFilename();

		my $cmd = self!generate-command($uri, $tf, $data);

		try {
			shellExec($cmd);
			CATCH {
				default {
					note "Command '" ~ $cmd ~ "' failed.";
					$tf.IO.unlink;
					...
				}
			}
		}

		my $str = $tf.IO.slurp;

		$tf.IO.unlink;

		return $str;
	}

	method !generate-command(Str $uri, Str $file, $data) {
		my $cmd;

		if $data ~~ /wget||curl/ {
			$cmd = %COMMAND{$data};
		}
		else {
			$cmd = $data;
		}
		$cmd.subst("%URI%", $uri);
		$cmd.subst("%FILE%",$file);
		$cmd;
	}
}

class Downloader::Module does Downloader {
	# NOT IMPL
}

#| read from local cache
class Downloader::Cache does Downloader {
	method get(Str $file, $data) {
		self!parsefile($file);
	}

	method !parsefile(Str $file) {
		my Errno @errnos = [];

		for $file.IO.lines -> $line {
			if $line ~~ /^errno\:(.*)\, number\:(.*)\, comment\:(.*)/ {
				my Errno $errno;
				$errno.errno = ~$0;
				$errno.number = ~$1;
				$errno.comment = ~$2;
				@errnos.push: $errno;
			}
		}

		@errnos;
	}
}