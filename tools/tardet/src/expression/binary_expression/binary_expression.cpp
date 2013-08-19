/*
 * binary_expression.cpp
 *
 *  Created on: 23.07.2013
 *      Author: jucs
 */

#include <memory>
#include <stdlib.h>
#include <stdio.h>
#include <string>
#include "../expressions.h"
#include "binary_expression.h"

using namespace std;

string binary_expression::print_inner(string op) {
	return "(" + left->print_inner() + " " + op + " " + right->print_inner() + ")";
}

char binary_expression::contains(rreil_variable *variable) {
	return left->contains(variable) || right->contains(variable);
}

bool binary_expression::substitute(struct rreil_variable *old,
		shared_ptr<expression> &new_) {

	shared_ptr<expression> left_new = new_;
	bool subst_left = left->substitute(old, left_new);
	if(!subst_left)
		left_new = left;
	shared_ptr<expression> right_new = new_;
	bool subst_right = right->substitute(old, right_new);
	if(!subst_right)
		right_new = right;

	if(subst_left || subst_right) {
		new_ = shared_ptr<expression>(construct(left_new, right_new));
		return 1;
	} else
		return 0;
}

char binary_expression::evaluate(uint64_t *result) {
	uint64_t left_result;
	char evalable = left->evaluate(&left_result);
	if(!evalable)
		return 0;
	uint64_t right_result;
	evalable = right->evaluate(&right_result);
	if(!evalable)
		return 0;
	*result = evaluate(left_result, right_result);
	return 1;
}

shared_ptr<expression> binary_expression::simplify() {
	left = left->simplify();
	right = right->simplify();
	if(left->is_dead() || right->is_dead())
		return make_shared<unevalable>();
	if(left->is_trivial() && right->is_trivial()) {
		uint64_t a;
		left->evaluate(&a);
		uint64_t b;
		right->evaluate(&b);
		return make_shared<immediate>(evaluate(a, b), get_size());
	} else
		return shared_from_this();
}
