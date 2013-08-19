/*
 * zx_expression.cpp
 *
 *  Created on: Aug 7, 2013
 *      Author: jucs
 */

#include <stdlib.h>
#include <stdio.h>
#include <stdint.h>
#include <string>
#include "../../util.hpp"
#include "../expressions.h"
#include "sx_expression.h"
extern "C" {
#include <context.h>
#include <simulator/ops.h>
}

sx_expression::sx_expression(shared_ptr<expression> operand, size_t to_size) :
		expression(to_size) {
	this->operand = operand;
}

sx_expression::~sx_expression() {
	// TODO Auto-generated destructor stub
}

char sx_expression::contains(struct rreil_variable *variable) {
	return operand->contains(variable);
}

bool sx_expression::substitute(struct rreil_variable *old, shared_ptr<expression> &new_) {
	if(operand->substitute(old, new_)) {
		new_ = shared_ptr<expression>(new sx_expression(new_, get_size()));
		return true;
	}
}

char sx_expression::evaluate(uint64_t *result) {
	char evaluatable = operand->evaluate(result);
	if(!evaluatable)
		return false;

	struct data data;
	data.data = (uint8_t*)result;
	uint64_t defined = 0;
	data.defined = (uint8_t*)&defined;
	data.bit_length = operand->get_size();
	data = simulator_op_sx(get_size(), data);
	*result = *((uint64_t*)data.data);
	free(data.data);
	free(data.defined);

	return true;
}

string sx_expression::print_inner() {
	return string_format("([%lu->s%lu] %s", operand->get_size(), get_size(), operand->print_inner().c_str());
}

shared_ptr<expression> sx_expression::simplify() {
	operand = operand->simplify();
	if(operand->is_trivial()) {
		uint64_t me;
		evaluate(&me);
		return make_shared<immediate>(me, get_size());
	} else if(operand->is_dead())
		return make_shared<unevalable>();
	else
		return shared_from_this();
}
