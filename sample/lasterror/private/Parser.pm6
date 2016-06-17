

use v6;
use lib ".";

use RefOptionSet;
use library::NIException;
use Errno;

role Parser does RefOptionSet {
	method parse(Blob $data) returns Array {
		X::NotImplement.new().throw();
	}

	method parse(Str $data) returns Array {
		X::NotImplement.new().throw();
	}

	method parse(Errno @data) returns Array {
		return @data;
	}
}

class Parser::Win32 does Parser {

}

class Parser::Linux does Parser {

}