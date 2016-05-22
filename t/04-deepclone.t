
use v6;
use Test;
use Getopt::Kinoko::Option;
use Getopt::Kinoko::OptionSet;
use Getopt::Kinoko::DeepClone;

{
    my Option $opt = create-option("s=s");
    my Option $opt-copy = $opt.deep-clone;

    ok $opt.WHERE != $opt-copy.WHERE, "Option deep copy ok.";
}

{
    my OptionSet $optset .= new("s=s;a=a;");
    my OptionSet $optset-copy = $optset.deep-clone;

    ok $optset.WHERE != $optset-copy.WHERE, "OptionSet deep copy ok.";
}
