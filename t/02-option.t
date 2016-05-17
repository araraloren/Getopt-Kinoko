
use v6;
use Test;
use Getopt::Kinoko::Option;

{
	my @short 			= < i s a h b>;
	my @short-optional 	= < i! s! a! h! b! >;
	my @long 			= < integer string array hash boolean >;
	my @long-optional 	= < integer! string! array! hash! boolean!>;
	my @option 			= < e example e|example |example e| example| |e >;

	for @option X @short -> $os {
		my $opt := create-option($os.[0] ~ '=' ~ $os.[1]);

		nok $opt.is-force, "A optional short option.";

		given $opt.major-type {
			when /integer/ {
				isa-ok $opt, Option::Integer, "OK, create a Option::Integer.";
			}
			when /string/ {
				isa-ok $opt, Option::String, "OK, create a Option::String.";
			}
			when /array/ {
				isa-ok $opt, Option::Array, "OK, create a Option::Array.";
			}
			when /hash/ {
				isa-ok $opt, Option::Hash, "OK, create a Option::Hash.";
			}
			when /boolean/ {
				isa-ok $opt, Option::Boolean, "OK, create a Option::Boolean.";
			}
		}
	}

	for @option X @short-optional -> $os {
		my $opt := create-option($os.[0] ~ '=' ~ $os.[1]);

		ok $opt.is-force, "Not a optional short option.";

		given $opt.major-type {
			when /integer/ {
				isa-ok $opt, Option::Integer, "OK, create a Option::Integer.";
			}
			when /string/ {
				isa-ok $opt, Option::String, "OK, create a Option::String.";
			}
			when /array/ {
				isa-ok $opt, Option::Array, "OK, create a Option::Array.";
			}
			when /hash/ {
				isa-ok $opt, Option::Hash, "OK, create a Option::Hash.";
			}
			when /boolean/ {
				isa-ok $opt, Option::Boolean, "OK, create a Option::Boolean.";
			}
		}
	}

	for @option X @long -> $os {
		my $opt := create-option($os.[0] ~ '=' ~ $os.[1]);

		nok $opt.is-force, "A optional long option.";

		given $opt.major-type {
			when /integer/ {
				isa-ok $opt, Option::Integer, "OK, create a Option::Integer.";
			}
			when /string/ {
				isa-ok $opt, Option::String, "OK, create a Option::String.";
			}
			when /array/ {
				isa-ok $opt, Option::Array, "OK, create a Option::Array.";
			}
			when /hash/ {
				isa-ok $opt, Option::Hash, "OK, create a Option::Hash.";
			}
			when /boolean/ {
				isa-ok $opt, Option::Boolean, "OK, create a Option::Boolean.";
			}
		}
	}

	for @option X @long-optional -> $os {
		my $opt := create-option($os.[0] ~ '=' ~ $os.[1]);

		ok $opt.is-force, "Not a optional long option.";

		given $opt.major-type {
			when /integer/ {
				isa-ok $opt, Option::Integer, "OK, create a Option::Integer.";
			}
			when /string/ {
				isa-ok $opt, Option::String, "OK, create a Option::String.";
			}
			when /array/ {
				isa-ok $opt, Option::Array, "OK, create a Option::Array.";
			}
			when /hash/ {
				isa-ok $opt, Option::Hash, "OK, create a Option::Hash.";
			}
			when /boolean/ {
				isa-ok $opt, Option::Boolean, "OK, create a Option::Boolean.";
			}
		}
	}
}

subtest {

	my $callback-flag = False;

	my $opt = create-option(
			"c|count=i", value 	=> 2, 
			cb 		=> -> $value { ok 5 == $value, "callback called."; } 
		);

	{
		ok $opt.is-short, "short option check ok.";
		ok $opt.is-long, "long option check ok.";
		ok $opt.is-integer, "type check ok.";
		ok $opt.has-callback, "callback check ok.";
		ok $opt.has-value, "value exists check ok.";
	}
	{
		ok $opt.short-name eq "c", "short option name ok";
		ok $opt.long-name eq "count", "long option name ok";
	}

	{
		ok $opt.value eq 2, "option defalut value ok.";
		$opt.set-value-callback(5);
		ok $opt.value eq 5, "option set value ok.";
	}

	
}, "Integer option ok.";

subtest {

}, "String option ok.";

done-testing;