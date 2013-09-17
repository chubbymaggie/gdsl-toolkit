#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <time.h>
#include <bfd.h>
#include <xed-interface.h>
#include <gdsl.h>

#define NANOS 1000000000LL

struct decode_result {
	unsigned int decoded;
	unsigned int invalid;

	long time;
};

static struct decode_result xed_decode_blob(unsigned char *blob, size_t size) {
	struct decode_result result;
	memset(&result, 0, sizeof(result));

	struct timespec start;
	struct timespec end;

	xed_state_t state;
	xed_decoded_inst_t insnObj;
	xed_decoded_inst_t* insn = &insnObj;
	xed_tables_init();
	xed_state_zero(&state);
	state.mmode = XED_MACHINE_MODE_LONG_64;
	state.stack_addr_width = XED_ADDRESS_WIDTH_32b;
	xed_decoded_inst_zero_set_mode(insn, &state);
	xed_decoded_inst_set_input_chip(insn, XED_CHIP_INVALID);
	char insnstr[128];
	unsigned int len;
	unsigned char* blobb = blob;
	xed_error_enum_t r;

	clock_gettime(CLOCK_REALTIME, &start);
	do {
		xed_decoded_inst_zero_set_mode(insn, &state);
		xed_decoded_inst_set_input_chip(insn, XED_CHIP_INVALID);
		r = xed_decode(insn, blobb, size);
		if(r == XED_ERROR_NONE) {
			len = xed_decoded_inst_get_length(insn);
			xed_decoded_inst_dump_intel_format(insn, insnstr, 128, 0);
//			//printf("%-27s\n", insnstr);
			puts(insnstr);
		} else {
			result.invalid++;
			len = 1;
		}
		blobb += len;
		size -= len;
		result.decoded++;
	} while(len > 0 && size > 0);
	clock_gettime(CLOCK_REALTIME, &end);
	result.time = end.tv_sec * NANOS + end.tv_nsec - start.tv_nsec - start.tv_sec * NANOS;

	return result;
}

static struct decode_result gdsl_decode_blob(unsigned char *blob, size_t size) {
	struct decode_result result;
	memset(&result, 0, sizeof(result));

	struct timespec start;
	struct timespec end;

	state_t state = gdsl_init();
	gdsl_set_code(state, (char*)blob, size, 0);

	clock_gettime(CLOCK_REALTIME, &start);
	while(1) {
		if(setjmp(*gdsl_err_tgt(state))) {
//			fprintf(stderr, "decode failed: %s\n", gdsl_get_error_message(state));
//			result.invalid++;
			break;
		}
		obj_t insn = gdsl_decode(state, gdsl_config_mode64(state) | gdsl_config_default_opnd_sz_32(state));

		string_t fmt = gdsl_merge_rope(state, gdsl_pretty(state, insn));
		puts(fmt);

		gdsl_reset_heap(state);

		result.decoded++;
	}
	clock_gettime(CLOCK_REALTIME, &end);

	gdsl_destroy(state);

	result.time = end.tv_sec * NANOS + end.tv_nsec - start.tv_nsec - start.tv_sec * NANOS;

	return result;
}

int main(int argc, char** argv) {
	if(argc < 2)
		exit(1);
	const char* fn = argv[1];

	fprintf(stderr, "file is %s\n", fn);

	bfd_init();
	bfd* bfd = bfd_openr(fn, NULL);
	if(bfd == NULL)
		exit(1);

	if(!bfd_check_format(bfd, bfd_object))
		exit(1);

	asection* s = bfd_get_section_by_name(bfd, ".text");
	if(s == NULL)
		exit(1);

	unsigned char* blob;
	bfd_size_type sz = s->size;
	fprintf(stderr, ".text is %zu bytes\n", sz);

	if(!bfd_malloc_and_get_section(bfd, s, &blob))
		exit(1);

	struct decode_result xed_result = xed_decode_blob(blob, sz);
	struct decode_result gdsl_result = gdsl_decode_blob(blob, sz);

	fprintf(stderr, "XED: Decoded %u opcode sequences (%u invalid/unknown); time: %lf seconds\n", xed_result.decoded,
			xed_result.invalid, xed_result.time / (double)(1000000000));
	fprintf(stderr, "GDSL: Decoded %u opcode sequences (%u invalid/unknown); time: %lf seconds\n", gdsl_result.decoded,
			gdsl_result.invalid, gdsl_result.time / (double)(1000000000));

	return (0);
}