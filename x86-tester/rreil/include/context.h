/*
 * context.h
 *
 *  Created on: 15.05.2013
 *      Author: jucs
 */

#ifndef CONTEXT_H_
#define CONTEXT_H_

struct register_ {
	uint8_t *data;
	size_t data_bit_length;
	size_t data_size;
};

struct memory_allocation {
	uint8_t *data;
	size_t data_size;
	void *address;
};

typedef void (context_load_t)(uint8_t **, uint8_t *, uint64_t, uint64_t);
typedef void (context_store_t)(uint8_t *, uint8_t *, uint64_t, uint64_t);

struct context {
	struct register_ *virtual_registers;
	struct register_ *x86_registers;
	struct register_ *temporary_registers;
	struct {
		struct memory_allocation *allocations;
		size_t allocations_length;
		size_t allocations_size;
		context_load_t *load;
		context_store_t *store;
	} memory;

};

extern struct memory_allocation *memory_allocation_init(void *address);
extern struct context *context_init(context_load_t *load, context_store_t *store);
extern struct context *context_copy(struct context *source);
extern void context_free(struct context *context);
extern void context_x86_print(struct context *context);

#endif /* CONTEXT_H_ */
