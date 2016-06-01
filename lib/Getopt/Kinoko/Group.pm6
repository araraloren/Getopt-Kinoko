
use v6;

use Getopt::Kinoko::Option;

role Group {
    has Option @.group;

    method get() {
        @!group;
    }

    method push($value) {
        @!group.push: $value;
    }
}

class Group::Normal does Group { }

class Group::Radio does Group { }

class Group::Multi does Group { }

class Group::Common does Group { }
