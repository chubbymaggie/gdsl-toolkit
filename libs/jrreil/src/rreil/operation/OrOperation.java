package rreil.operation;

import rreil.linear.LinearExpression;

public class OrOperation extends BinaryOperation {

	public OrOperation(long size, LinearExpression operand1,
			LinearExpression operand2) {
		super(size, operand1, operand2);
	}
	
	@Override
	public String toString() {
		return operand1 + " |:" + size + " " + operand2;
	}
}