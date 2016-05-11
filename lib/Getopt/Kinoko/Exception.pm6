use v6;

class X::Kinoko is Exception {
    has $.msg handles <Str>;

    method message() {
        $!msg;
    }
}

#| throw this exception when parse failed
class X::Kinoko::Fail is Exception {
    has $.msg handles <Str>;

    method message() {
        $!msg;
    }
}

#| warnings
class W::Kinoko {
    has $.msg handles <Str>;

    method warn() {
        note "Warning: " ~ $!msg;
    }
}
