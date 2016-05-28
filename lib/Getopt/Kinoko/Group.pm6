
use v6;

use Getopt::Kinoko::Option;

rule Group {
    method get() { ... }
    method push($value) { ... }
    method has-value() { ... }
}

class Group::Normal does Group {
    has Option @.group;
}

class Group::Radio does Group {
    has Option @.group;
}

class Group::Multi does Group {
    has Option @.group;
}

class Group::Common does Group {
    has Option @.group;
}
