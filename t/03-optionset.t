
use v6;
use Test;
use Getopt::Kinoko;
use Getopt::Kinoko::OptionSet;

my OptionSet $optset .= new("n|name=s;v|vip=b!;");

isa-ok $optset, OptionSet, "OptionSet create ok";

lives-ok {
    $optset.push(
        "l|shopping-list=h",
    );
}, "push a new option ok";

lives-ok {
    $optset.push(
        "d|discount=i",
        98
    );
}, "push a new option has default value ok";

lives-ok {
    $optset.push(
        "s|sum=s", # not support float number option
        "0",
        callback => -> $value {
            die("sum can not be negative") if +$value < 0;
        }
    );
}, "push a new option has callback ok";

lives-ok {
    $optset.append("p|print-list=b;i|id=s;");
}, "append two new option ok";

# has
{
    ok $optset.has("p"), "check option p ok";
    ok $optset.has("p", :short), "check short option p ok";
    ok $optset.has("print-list", :long), "check long option print-list ok";
    nok $optset.has("w"), "check option w not ok";
}

#has-value
{
    ok $optset.has-value("d"), "option discount has value";
    nok $optset.has-value("l"), "shopping-list has no value";
}

# get
{
    my $opt-sl := $optset.get("l");

    does-ok $opt-sl, Option, "get option shopping-list ok";
    isa-ok $opt-sl, Option::Hash, "get option shopping-list ok";
}

# set-value set callback
{
    lives-ok {
        $optset.set-value("shopping-list", %(coffee => 1));
        $optset.set-callback("shopping-list", -> $value { say "current -> " ~ $value; });
    }, " set value, set callback ok";
}

# AT-KEY
{
    isa-ok $optset{'l'}, Hash, "get shopping-list value ok";
}

# EXISTS-KEY
{
    ok $optset{'l'}:exists, "check option exists ok";
}

# is-set-noa-callback set-noa-callback
{
    nok $optset.is-set-noa-callback(), "check noa callback ok";

    $optset.set-noa-callback(-> $noa {
        note " not a option argument: " ~ $noa;
    });
    ok $optset.is-set-noa-callback(), "check noa callback ok";
}

# push-*
{
    lives-ok {
        $optset.push-str(
            long => "not-using-option1",
            :!force
        );
        $optset.push-int(
            long => 'not-using-option2',
            callback => -> $value {
                ; # do nothing
            }
        );
        $optset.push-arr(
            long => 'not-using-option3',
            value => [1, 2]
        );
        $optset.push-hash(
            long => 'not-using-option4'
        );
        $optset.push-bool(
            long => 'not-using-option5'
        );
    }, "push option ok";
}

# parser
{
    my $gnu-style-optset = $optset.deep-clone;

    ok $gnu-style-optset.WHICH ne $optset.WHICH, "deep clone ok";

    my @args = [ "-n", "Jam", "--vip", "-l", ":ice-cream<1>",  "-l", "%(chips => 2)", "-d", "95", "some", "other", "noa" ];

    my @gargs = [ "-n=Jam", "--vip", "-l=%('ice-cream' => 1)",  "-l=%(chips => 2)", "-d=95" ];

    lives-ok {
        getopt($optset, @args, prefix => 'get-', :generate-method);
    }, "getopt normal style parse ok";

    lives-ok {
        getopt($gnu-style-optset, @gargs, :gnu-style);
    }, "getopt gnu-style parse ok";

    can-ok $optset, "get-p";
    can-ok $optset, "get-shopping-list";
}

done-testing;
