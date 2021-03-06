/*
 * gdrr_config.h
 *
 *  Created on: Mar 10, 2013
 *      Author: jucs
 */

#ifndef GDRR_CONFIG_H_
#define GDRR_CONFIG_H_

#include <gdsl.h>
#include "gdrr_callbacks.h"
#include "gdrr_arch_callbacks.h"

enum gdrr_config_stmts_handling {
	GDRR_CONFIG_STMTS_HANDLING_RECURSIVE, GDRR_CONFIG_STMTS_HANDLING_LIST
};

struct gdrr_config {
	struct {
		struct gdrr_sem_id_callbacks sem_id;
		struct gdrr_sem_address_callbacks sem_address;
		struct gdrr_sem_var_callbacks sem_var;
		struct gdrr_sem_linear_callbacks sem_linear;
		struct gdrr_sem_sexpr_callbacks sem_sexpr;
		struct gdrr_sem_op_cmp_callbacks sem_op_cmp;
		struct gdrr_sem_op_callbacks sem_op;
		struct gdrr_sem_stmt_callbacks sem_stmt;
		struct gdrr_branch_hint_callbacks branch_hint;
		union {
			struct gdrr_sem_stmts_callbacks sem_stmts;
			struct gdrr_sem_stmts_list_callbacks sem_stmts_list;
		};
		struct gdrr_arch_callbacks arch;
	} callbacks;
	enum gdrr_config_stmts_handling gdrr_config_stmts_handling;
	void *userdata;
	state_t state;
};


#endif /* GDRR_CONFIG_H_ */
