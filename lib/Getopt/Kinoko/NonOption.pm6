
use v6;

use Getopt::Kinoko::Exception;

rule NonOption {
    has &.callback;
}

class NonOption::Front does NonOption {
    method new(:&callback) {
            self.bless(:$callback);
    }

    method process(Argument $arg) returns Bool {
        if $arg.index != 1 {
            throw X::Kinoko.new(msg => "NonOption::Front: " ~ $.value ~ " is not front argument.");
        }
        else {
            return &!callback($arg);
        }
    }
}
