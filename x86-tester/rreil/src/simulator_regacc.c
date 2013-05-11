/*
 * simulator_regacc.c
 *
 *  Created on: 08.05.2013
 *      Author: jucs
 */

#include <stdlib.h>
#include <stdio.h>
#include <stdint.h>
#include <rreil/rreil.h>
#include <simulator.h>
#include <simulator_regacc.h>

static void simulator_register_assign(struct simulator_context *context,
		struct rreil_id *id, uint8_t *data, size_t bit_length, size_t bit_offset,
		void (*function)(struct register_ *, uint8_t*, size_t, size_t)) {
	switch(id->type) {
		case RREIL_ID_TYPE_VIRTUAL: {
			function(&context->virtual_registers[id->virtual], data, bit_length,
					bit_offset);
			break;
		}
		case RREIL_ID_TYPE_TEMPORARY: {
			function(&context->temporary_registers[id->temporary], data, bit_length,
					bit_offset);
			break;
		}
		case RREIL_ID_TYPE_X86: {
			function(&context->x86_registers[id->x86], data, bit_length, bit_offset);
			break;
		}
	}
}

static void simulator_register_generic_read(struct register_ *reg,
		uint8_t *buffer, size_t bit_length, size_t bit_offset) {
	uint8_t byte_read(uint8_t length) {
		if(length == 8 && !(bit_offset % 8))
			return reg->data[bit_offset / 8];

		uint8_t local = bit_offset % 8;
		uint8_t low = reg->data[bit_offset / 8];
		uint8_t high = reg->data[bit_offset / 8 + 1];

		uint16_t word = (high << 8) | low;

		word >>= local;

		uint16_t mask = (1 << length) - 1;

		return (uint8_t)(word & mask);
	}

	while(bit_length >= 8) {
		*(buffer++) = byte_read(8);
		bit_length -= 8;
		bit_offset += 8;
	}

	if(bit_length)
		*(buffer++) = byte_read(bit_length);
}

void simulator_register_read(struct simulator_context *context,
		struct rreil_id *id, uint8_t *buffer, size_t bit_length, size_t bit_offset) {
	simulator_register_assign(context, id, buffer, bit_length, bit_offset,
			&simulator_register_generic_read);
}

void simulator_register_read_8(struct simulator_context *context,
		struct rreil_id *id, uint8_t *buffer, size_t bit_offset) {
	simulator_register_read(context, id, buffer, 8, bit_offset);
}

void simulator_register_read_16(struct simulator_context *context,
		struct rreil_id *id, uint8_t *buffer, size_t bit_offset) {
	simulator_register_read(context, id, buffer, 16, bit_offset);
}

void simulator_register_read_32(struct simulator_context *context,
		struct rreil_id *id, uint8_t *buffer, size_t bit_offset) {
	simulator_register_read(context, id, buffer, 32, bit_offset);
}

void simulator_register_read_64(struct simulator_context *context,
		struct rreil_id *id, uint8_t *buffer, size_t bit_offset) {
	simulator_register_read(context, id, buffer, 64, bit_offset);
}

void simulator_register_generic_write(struct register_ *reg,
		uint8_t *data, size_t bit_length, size_t bit_offset) {
	if(bit_offset / 8 + 1 + bit_length / 8 + 1 > reg->data_size) {
		reg->data_size = bit_offset / 8 + 1 + bit_length / 8 + 1;
		reg->data = (uint8_t*)realloc(reg->data, reg->data_size);
	}

	if(bit_offset + bit_length > reg->data_bit_length)
		reg->data_bit_length = bit_offset + bit_length;

	void byte_write(uint8_t data, uint8_t length, size_t offset) {
		if(offset % 8 || length < 8) {
			uint8_t local = offset % 8;
			uint8_t low = reg->data[offset / 8];
			uint8_t high = reg->data[offset / 8 + 1];

			uint8_t length_mask = (1 << length) - 1;
			data &= length_mask;

//			uint8_t mask = (1 << local) - 1; => mask / ~mask
			low &= ~(length_mask << local);
			high &= ~(length_mask >> (8 - local));

			low |= data << local;
			high |= data >> (8 - local);

			reg->data[offset / 8] = low;
			reg->data[offset / 8 + 1] = high;
		} else
			reg->data[offset / 8] = data;
	}

	while(bit_length >= 8) {
		byte_write(*(data++), 8, bit_offset);
		bit_offset += 8;
		bit_length -= 8;
	}

	if(bit_length)
		byte_write(*data, bit_length, bit_offset);
}

void simulator_register_write(struct simulator_context *context,
		struct rreil_id *id, uint8_t *data, size_t bit_length, size_t bit_offset) {
	simulator_register_assign(context, id, data, bit_length, bit_offset,
			&simulator_register_generic_write);
}

void simulator_register_write_8(struct simulator_context *context,
		struct rreil_id *id, uint8_t data, size_t bit_offset) {
	simulator_register_write(context, id, &data, sizeof(data) * 8, bit_offset);
}

void simulator_register_write_16(struct simulator_context *context,
		struct rreil_id *id, uint16_t data, size_t bit_offset) {
	simulator_register_write(context, id, (uint8_t*)&data, sizeof(data) * 8, bit_offset);
}

void simulator_register_write_32(struct simulator_context *context,
		struct rreil_id *id, uint32_t data, size_t bit_offset) {
	simulator_register_write(context, id, (uint8_t*)&data, sizeof(data) * 8, bit_offset);
}

void simulator_register_write_64(struct simulator_context *context,
		struct rreil_id *id, uint64_t data, size_t bit_offset) {
	simulator_register_write(context, id, (uint8_t*)&data, sizeof(data) * 8, bit_offset);
}
