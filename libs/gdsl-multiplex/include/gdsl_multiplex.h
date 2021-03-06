/*
 * gdsl_multiplex.h
 *
 *  Created on: Sep 11, 2013
 *      Author: jucs
 */

#ifndef GDSL_MULTIPLEX_H_
#define GDSL_MULTIPLEX_H_

#include <gdsl_generic.h>
#include <setjmp.h>
#include <stdint.h>
#include <stdlib.h>

struct frontend_desc {
  const char *name;
  const char *ext;
};

struct frontend {
  struct {
    state_t (*init)();
    void (*set_code)(state_t state, unsigned char *buffer, uint64_t size, uint64_t base);
    char (*seek)(state_t state, int_t ip);
    jmp_buf *(*err_tgt)(state_t s);
    string_t (*merge_rope)(state_t s, obj_t rope);
    char* (*get_error_message)(state_t s);
    uint64_t (*get_ip)(state_t s);
    void (*reset_heap)(state_t state);
    void (*destroy)(state_t state);
  } generic;

  struct {
    int_t (*config_default)(state_t state);
    obj_t (*decoder_config)(state_t state);
    int_t (*has_conf)(state_t state, obj_t config);
    obj_t (*conf_next)(state_t state, obj_t config);
    string_t (*conf_short)(state_t state, obj_t config);
    string_t (*conf_long)(state_t state, obj_t config);
    int_t (*conf_data)(state_t state, obj_t config);
    obj_t (*decode)(state_t state, int_t config);
    obj_t (*generalize)(state_t state, obj_t insn);
    obj_t (*asm_convert_insn)(state_t s, asm_callbacks_t cbs, asm_insn_t insn);
    obj_t (*pretty)(state_t state, obj_t insn);
  } decoder;

  struct {
    obj_t (*translate)(state_t state, obj_t insn);
    obj_t (*pretty)(state_t state, obj_t rreil);
    obj_t (*pretty_arch_id)(state_t state, obj_t id);
    obj_t (*pretty_arch_exception)(state_t state, obj_t id);
    obj_t (*rreil_convert_sem_stmt_list)(state_t s, callbacks_t cbs, obj_t stmts);
    obj_t (*optimization_config)(state_t state);
    opt_result_t (*decode_translate_block_optimized)(state_t state, int_t config, int_t limit, int_t pres);
    obj_t (*traverse_insn_list)(state_t state, obj_t insn_list, obj_t insns_init,
        obj_t (*insn_cb)(state_t, obj_t, obj_t));
  } translator;

  void *dl;
};

#define GDSL_MULTIPLEX_ERROR_NONE 0
#define GDSL_MULTIPLEX_ERROR_FRONTENDS_PATH_NOT_SET 1
#define GDSL_MULTIPLEX_ERROR_UNABLE_TO_OPEN 2
#define GDSL_MULTIPLEX_ERROR_SYMBOL_NOT_FOUND 3

extern size_t gdsl_multiplex_frontends_list(struct frontend_desc **descs);
extern size_t gdsl_multiplex_frontends_list_with_base(struct frontend_desc **descs, char const *base);
extern char gdsl_multiplex_frontend_get_by_desc(struct frontend *frontend, struct frontend_desc desc);
extern char gdsl_multiplex_frontend_get_by_lib_name(struct frontend *frontend, char const *name);
extern void gdsl_multiplex_descs_free(struct frontend_desc *descs, size_t descs_length);
extern void gdsl_multiplex_frontend_close(struct frontend *frontend);

#endif /* GDSL_MULTIPLEX_H_ */
