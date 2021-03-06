/*
 * tester.c
 *
 *  Created on: 15.05.2013
 *      Author: jucs
 */

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <sys/mman.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <unistd.h>
#include <rreil/rreil.h>
#include <rreil/gdrr_builder.h>
#include <x86.h>
#include <simulator/simulator.h>
#include <simulator/regacc.h>
#include <simulator/tracking.h>
#include <memory.h>
#include <util.h>
#include <tbgen.h>
#include <gdwrap.h>
#include <gdsl.h>
#include <context.h>
#include <executor.h>
#include <tester.h>

static uint8_t *data_template;

static void copy_buffer(uint8_t *data, size_t bit_length) {
  for(size_t i = 0; i < bit_length / 8 + (bit_length % 8 > 0); ++i)
    data[i] = data_template[i];
}

static void zero_buffer(uint8_t *data, size_t bit_length) {
  for(size_t i = 0; i < bit_length / 8 + (bit_length % 8 > 0); ++i)
    data[i] = 0;
}

static void rand_buffer(uint8_t *data, size_t bit_length) {
  for(size_t i = 0; i < bit_length / 8 + (bit_length % 8 > 0); ++i)
    data[i] = rand() * (rand() > RAND_MAX / 4);
}

static void rand_address_buffer(uint8_t *data, size_t bit_length) {
  if(bit_length != 64) {
    rand_buffer(data, bit_length);
    return;
  }

  for(size_t i = 0; i < bit_length / 8 + (bit_length % 8 > 0); ++i) {
    if(!i) data[i] = rand() & 0xf0;
    else if(i < 5) data[i] = rand();
//			else if(i == 6)
//				data[i] = 0x7f;
    else data[i] = 0;

//		data[i] &= 0x7f;
  }
}

static void tester_register_fill(struct context *context, enum x86_id reg, void (*filler)(uint8_t *, size_t)) {
  switch(reg) {
    case X86_ID_GS_Base: {
      void *gs_base = executor_segment_base_get(reg);
      data_template = (uint8_t*)&gs_base;
      filler = &copy_buffer;
      break;
    }
    case X86_ID_FS_Base: {
      void *fs_base = executor_segment_base_get(reg);
      data_template = (uint8_t*)&fs_base;
      filler = &copy_buffer;
      break;
    }
    default: {
      break;
    }
  }

  size_t length = x86_amd64_sizeof(reg);
  uint8_t *buffer = (uint8_t*)malloc(length / 8 + 1);
  filler(buffer, length);

  struct data data;
  data.data = buffer;
  data.bit_length = length;
  context_data_define(&data);

  simulator_register_generic_write(&context->x86_registers[reg], data, 0);

  context_data_clear(&data);
}

static void tester_access_init(struct context *context, struct register_access *access,
    void (*filler)(uint8_t *, size_t)) {
  for(size_t i = 0; i < access->x86_indices_length; ++i) {
    size_t index = access->x86_indices[i];
    enum x86_id reg = (enum x86_id)index;

    tester_register_fill(context, reg, filler);
  }
}

static void registers_x86_rreil_init(struct context *context_rreil, struct tracking_trace *trace, char test_unused) {
  void (*rand)(uint8_t*, size_t);
  if(trace->mem.used) rand = &rand_address_buffer;
  else rand = &rand_buffer;

  if(test_unused) {
    for(size_t i = 0; i < X86_ID_COUNT; ++i)
      tester_register_fill(context_rreil, (enum x86_id)i, rand);
  } else {
    tester_access_init(context_rreil, &trace->reg.written, &zero_buffer);
//	tester_access_init(context_rreil, &trace->reg.read, &rand_buffer);

    tester_access_init(context_rreil, &trace->reg.read, rand);
    tester_access_init(context_rreil, &trace->reg.dereferenced, rand);
  }

  executor_rflags_clean(context_rreil);
  executor_virt_calc(context_rreil);
}

static void ip_set(struct context *context_rreil, struct context *context_cpu, void *instruction_address,
    size_t instruction_length) {
  struct data insn_address;
  insn_address.data = (uint8_t*)&instruction_address;
  insn_address.bit_length = sizeof(instruction_address) * 8;
  context_data_define(&insn_address);

  simulator_register_generic_write(&context_rreil->x86_registers[X86_ID_IP], insn_address, 0);

  size_t next_instruction_address = (size_t)instruction_address + instruction_length;
  insn_address.data = (uint8_t*)&next_instruction_address;

  simulator_register_generic_write(&context_cpu->x86_registers[X86_ID_IP], insn_address, 0);

  free(insn_address.defined);
}

struct context_callback_closure {
  struct context *context_cpu;
  struct context *context_rreil;
  struct tracking_trace *trace;
};

void load(void *closure, uint8_t **buffer, uint8_t *address, uint64_t address_size, uint64_t access_size) {
  struct context_callback_closure *cls = (struct context_callback_closure*)closure;

  uint8_t *source = (uint8_t*)malloc(access_size / 8);
  for(size_t i = 0; i < access_size / 8; ++i)
    source[i] = rand();
  memory_load(cls->context_rreil, buffer, address, address_size, access_size, source);
  memory_load(cls->context_cpu, buffer, address, address_size, access_size, source);

  printf("[Debug] Random data for address 0x");
  for(size_t i = address_size / 8; i > 0; --i)
    printf("%02x", address[i - 1]);
  printf(": ");
  for(size_t i = access_size / 8; i > 0; --i)
    printf("%02x", source[i - 1]);
  printf("\n");

  free(source);
}

void store(void *closure, uint8_t *buffer, uint8_t *address, uint64_t address_size, uint64_t access_size) {
  struct context_callback_closure *cls = (struct context_callback_closure*)closure;

  memory_store(cls->context_rreil, buffer, address, address_size, access_size);
  struct memory_access access;
  access.address = memory_ptr_get(address, address_size);
  access.data_size = access_size / 8;
  tracking_trace_memory_write_add(cls->trace, access);
}

void jump(void *closure, uint8_t *address, uint64_t address_size) {
  struct context_callback_closure *cls = (struct context_callback_closure*)closure;

  memory_jump(cls->context_rreil, address, address_size);
  memory_jump(cls->context_cpu, address, address_size);
}

struct tester_result tester_test_translated(struct rreil_statements *statements, uint8_t *instruction,
    size_t instruction_length, char test_unused) {
  struct tester_result result;
  result.type = TESTER_RTYPE_SUCCESS;

  rreil_statements_print(stdout, statements);

  struct context *context_cpu;
  struct context *context_rreil;
  struct tracking_trace *trace = tracking_trace_init();

  struct context_callback_closure cls;

  context_rreil = context_init(&load, &store, &jump, &cls);

  tracking_statements_trace(trace, statements);

//	if(!trace->reg.dereferenced.x86_indices_length && !trace->reg.read.x86_indices_length
//			&& !trace->reg.written.x86_indices_length && !trace->mem.used) {
//		printf("Instruction without any effects, aborting...\n");
//		goto cu_b;
//	}

  printf("------------------\n");
  tracking_trace_print(trace);

  registers_x86_rreil_init(context_rreil, trace, test_unused);

  context_cpu = context_copy(context_rreil);

  cls.context_cpu = context_cpu;
  cls.context_rreil = context_rreil;
  cls.trace = trace;

  void *code;
  void *instruction_address;
  struct tbgen_result tbgen_result = executor_instruction_mapped_generate(instruction, instruction_length, trace,
      context_cpu, &code, &instruction_address, test_unused);
  if(tbgen_result.result != TBGEN_RTYPE_SUCCESS) {
    result.type = TESTER_RTYPE_TBGEN_ERROR;
    goto cu_c;
  }

  ip_set(context_rreil, context_cpu, instruction_address, instruction_length);

  printf("------------------\n");
  context_x86_print(context_rreil);

  char exception = 0;

  enum simulator_error simulation_error = simulator_statements_simulate(context_rreil, statements);
  switch(simulation_error) {
    case SIMULATOR_ERROR_NONE: {
      break;
    }
    case SIMULATOR_ERROR_EXCEPTION: {
      exception = 1;
      break;
    }
    default: {
      result.type = TESTER_RTYPE_SIMULATION_ERROR;
      result.simulator_error = simulation_error;
      goto cu_a;
    }
  }

  struct execution_result execution_result = executor_instruction_execute(instruction, instruction_length, trace,
      context_cpu, code, tbgen_result);
  switch(execution_result.type) {
    case EXECUTION_RTYPE_SUCCESS: {
      break;
    }
    case EXECUTION_RTYPE_SIGNAL: {
      if(exception) {
        printf("Received signal while expecting signal due to a simulation exception.\n");
        result.type = TESTER_RTYPE_SUCCESS;
        goto cu_a;
      }
    }
    default: {
      result.type = TESTER_RTYPE_EXECUTION_ERROR;
      result.execution_result = execution_result;
      goto cu_a;
    }
  }

  if(exception) {
    printf("Received no signal while expecting signal due to a simulation exception.\n");
    result.type = TESTER_RTYPE_COMPARISON_ERROR;
    goto cu_a;
  }

//	tester_rflags_clean(context_cpu);

  printf("------------------\n");
  printf("CPU:\n");
  context_x86_print(context_cpu);
  printf("Rreil simulator:\n");
  context_x86_print(context_rreil);

  printf("------------------\n");
//	if(!retval) {
  char retval = context_compare_print(trace, context_cpu, context_rreil, test_unused);
  if(retval) result.type = TESTER_RTYPE_COMPARISON_ERROR;
//	} else
//		printf(
//				"Comparison skipped because of the failure to execute the test function.\n");

  cu_a: ;

  free(tbgen_result.buffer);
  free(tbgen_result.jump_marker);

  munmap(code, tbgen_result.buffer_length);

  cu_c: ;

  context_free(context_cpu);

//	cu_b: ;
  tracking_trace_free(trace);
  context_free(context_rreil);

  return result;
}

static struct tester_result tester_forked_test_translated(char fork_, struct rreil_statements *statements,
    uint8_t *instruction, size_t instruction_length, char test_unused) {
  struct tester_result result;
  if(fork_) {
    struct tester_result *translated_result = mmap(NULL, sizeof(enum tester_result_type), PROT_READ | PROT_WRITE,
    MAP_SHARED | MAP_ANONYMOUS, 0, 0);
    translated_result->type = TESTER_RTYPE_CRASH;

    pid_t pid = fork();
    if(!pid) {
      *translated_result = tester_test_translated(statements, instruction, instruction_length, test_unused);
      exit(0);
    } else waitpid(pid, NULL, 0);
    result = *translated_result;
    munmap(translated_result, sizeof(enum tester_result_type));
  } else result = tester_test_translated(statements, instruction, instruction_length, test_unused);

  return result;
}

struct tester_result tester_test_binary(void (*name)(char *), char fork_, uint8_t *data, size_t data_size,
    char test_unused) {
  struct tester_result result;
  result.type = TESTER_RTYPE_SUCCESS;

  state_t state = gdsl_init();
  gdsl_set_code(state, data, data_size, 0);

  obj_t insn;
  int_t features;
  if(gdwrap_decode(state, &insn)) {
    printf("Decode failed\n");
    fflush(stderr);
    fflush(stdout);
    result.type = TESTER_RTYPE_DECODING_ERROR;
    goto cu;
  }

  printf("Instruction bytes:");
  for(size_t i = 0; i < data_size; ++i)
    printf(" %02x", (int)(data[i]) & 0xff);
  printf("\n");

  fflush(stdout);
  data_size = gdsl_get_ip(state);
  features = gdsl_features_get(state, insn);

  printf("[");
  for(size_t i = 0; i < data_size; ++i) {
    if(i) printf(" ");
    printf("%02x", data[i]);
  }
  printf("] ");

  char *str = gdwrap_x86_pretty(state, insn, GDSL_X86_PRINT_MODE_FULL);
  if(str) puts(str);
  else printf("NULL\n");
//	free(str);

  str = gdwrap_x86_pretty(state, insn, GDSL_X86_PRINT_MODE_SIMPLE);
  if(str) {
    puts(str);
    if(name) name(str);
  } else printf("NULL\n");
//	free(str);

  printf("---------------------------\n");

  obj_t rreil;
  if(gdwrap_translate(state, &rreil, insn)) {
    printf("Translate failed\n");
    fflush(stderr);
    fflush(stdout);
    result.type = TESTER_RTYPE_TRANSLATION_ERROR;
    goto cu;
  }

  callbacks_t callbacks = rreil_gdrr_builder_callbacks_get(state);
  struct rreil_statements *statements = (struct rreil_statements*)gdsl_rreil_convert_sem_stmt_list(state, callbacks,
      rreil);
  free(callbacks);

  result = tester_forked_test_translated(fork_, statements, data, data_size, test_unused);

  rreil_statements_free(statements);

  cu: ;

  gdsl_destroy(state);

  result.features = features;
  return result;
}

void tester_result_type_print(enum tester_result_type result_type) {
  switch(result_type) {
    case TESTER_RTYPE_SUCCESS: {
      printf("TESTER_RESULT_SUCCESS");
      break;
    }
    case TESTER_RTYPE_DECODING_ERROR: {
      printf("TESTER_RESULT_DECODING_ERROR");
      break;
    }
    case TESTER_RTYPE_TRANSLATION_ERROR: {
      printf("TESTER_RESULT_TRANSLATION_ERROR");
      break;
    }
    case TESTER_RTYPE_TBGEN_ERROR: {
      printf("TESTER_RTYPE_TBGEN_ERROR");
      break;
    }
    case TESTER_RTYPE_SIMULATION_ERROR: {
      printf("TESTER_RESULT_SIMULATION_ERROR");
      break;
    }
    case TESTER_RTYPE_EXECUTION_ERROR: {
      printf("TESTER_RESULT_EXECUTION_ERROR");
      break;
    }
    case TESTER_RTYPE_COMPARISON_ERROR: {
      printf("TESTER_RESULT_COMPARISON_ERROR");
      break;
    }
    case TESTER_RTYPE_CRASH: {
      printf("TESTER_RESULT_CRASH");
      break;
    }
  }
}
