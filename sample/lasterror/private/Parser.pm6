

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

class Parser::Win32System does Parser {
	method parse(Str $data) returns Array {

	}
}

class Parser::Win32Socket does Parser {
	method parse(Str $data) returns Array {

	}
}

class Parser::Linux does Parser {

}
