
use v6;

role DeepClone {

	multi sub clone-helper(\c) { c }

	multi sub clone-helper(DeepClone \c) { c.deep-clone }

	multi method deep-clone(Array:D:) {
		self>>.&clone-helper;
	}

	multi method deep-clone(Hash:D:) {
		self>>.&clone-helper;
	}

	multi method deep-clone(Str:D:) {
		self.Str;
	}

	multi method deep-clone(@array) {
		@array>>.&clone-helper;
	}

	multi method deep-clone(%hash) {
		%hash>>.&clone-helper;
	}

	multi method deep-clone(Str $str ) {
		$str.Str;
	}

	multi method deep-clone($other) {
		$other;
	}

	multi method deep-clone() {
		self;
	}
}