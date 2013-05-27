/*
 * tester.h
 *
 *  Created on: 15.05.2013
 *      Author: jucs
 */

#ifndef TESTER_H_
#define TESTER_H_

#include <stdlib.h>
#include <stdint.h>
#include <rreil/rreil.h>
#include <dis.h>

enum tester_result {
	TESTER_RESULT_SUCCESS = 0,
	TESTER_RESULT_DECODING_ERROR = 1,
	TESTER_RESULT_TRANSLATION_ERROR = 2,
	TESTER_RESULT_SIMULATION_ERROR = 3,
	TESTER_RESULT_EXECUTION_ERROR = 4,
	TESTER_RESULT_COMPARISON_ERROR = 5,
	TESTER_RESULT_CRASH = 6
};

#define TESTER_RESULTS_LENGTH (TESTER_RESULT_CRASH + 1)

extern enum tester_result tester_test_translated(struct rreil_statements *statements, uint8_t *instruction,
		size_t instruction_length);
extern enum tester_result tester_test_binary(void (*name)(char *), char fork_, __char *data,
		size_t data_size);
extern void tester_result_print(enum tester_result result);

#endif /* TESTER_H_ */
