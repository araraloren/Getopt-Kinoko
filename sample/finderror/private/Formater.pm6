
use v6;

use RefOptionSet;
use library::NIException;

role Formater does RefOptionSet {
	method format(@out) {
		X::NotImplement.new().throw();
	}
}

class Formater::Normal does Formater {
	method format(@out) {
		@out;
	}
}

class Formater::Table does Formater {

}
