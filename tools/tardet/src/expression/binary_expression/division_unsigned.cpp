
#include <stdint.h>
#include <string>
#include "division_unsigned.h"

uint64_t division_unsigned::evaluate(uint64_t a, uint64_t b) {
	return a / b;
}

expression *division_unsigned::construct(shared_ptr<expression> left,
		shared_ptr<expression> right) {
	return new division_unsigned(left, right, size_get());
}

string division_unsigned::print_inner() {
	return binary_expression::print_inner("/u");
}

