#include <jni.h>
#include <stdio.h>
#include <stdlib.h>
#include <dis.h>
#include <gdrr.h>
#include "rnati_NativeInterface.h"

//gcc -std=c99 -fPIC -shared -Wl,-soname,libjgdrr.so -I/usr/lib/jvm/java-6-openjdk-amd64/include -I../.. -I../../include ../../dis.o -o ../bin/libjgdrr.so rnati_NativeInterface.c ../../gdrr/Debug/libgdrr.a
//echo "48 83 ec 08" | java -ss134217728 -Djava.library.path=. Program

struct closure {
	JNIEnv *env;
	jobject obj;
};

static jobject java_method_call(void *closure, char *name, int numargs, ...) {
	if(numargs > 3)
		return NULL; //Todo: Handle error

	struct closure *cls = (struct closure*)closure;

	jclass class = (*cls->env)->GetObjectClass(cls->env, cls->obj);

	char *signature;
	switch(numargs) {
		case 0: {
			signature = "()Ljava/lang/Object;";
			break;
		}
		case 1: {
			signature = "(Ljava/lang/Object;)Ljava/lang/Object;";
			break;
		}
		case 2: {
			signature = "(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;";
			break;
		}
		case 3: {
			signature =
					"(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;";
			break;
		}
	}
	jmethodID mid = (*cls->env)->GetMethodID(cls->env, class, name, signature);

	jobject args[numargs];

	va_list list;
	va_start(list, numargs);
	for(int i = 0; i < numargs; ++i)
		args[i] = va_arg(list, jobject);
	va_end(list);

	jobject ret;
	switch(numargs) {
		case 0: {
			ret = (*cls->env)->CallObjectMethod(cls->env, cls->obj, mid);
			break;
		}
		case 1: {
			ret = (*cls->env)->CallObjectMethod(cls->env, cls->obj, mid, args[0]);
			break;
		}
		case 2: {
			ret = (*cls->env)->CallObjectMethod(cls->env, cls->obj, mid, args[0],
					args[1]);
			break;
		}
		case 3: {
			ret = (*cls->env)->CallObjectMethod(cls->env, cls->obj, mid, args[0],
					args[1], args[2]);
			break;
		}
	}

	return ret;
}

static jobject java_long_create(void *closure, long int x) {
	struct closure *cls = (struct closure*)closure;

	jclass class = (*cls->env)->FindClass(cls->env, "java/lang/Long");
	jmethodID method_id = (*cls->env)->GetMethodID(cls->env, class, "<init>",
			"(J)V");
	jobject a = (*cls->env)->NewObject(cls->env, class, method_id, x);

	return a;
}

// sem_id
static gdrr_sem_id_t *virt_eq(void *closure) {
	jobject ret = java_method_call(closure, "virt_eq", 0);
	return (gdrr_sem_id_t*)ret;
}
static gdrr_sem_id_t *virt_neq(void *closure) {
	jobject ret = java_method_call(closure, "virt_neq", 0);
	return (gdrr_sem_id_t*)ret;
}
static gdrr_sem_id_t *virt_les(void *closure) {
	jobject ret = java_method_call(closure, "virt_les", 0);
	return (gdrr_sem_id_t*)ret;
}
static gdrr_sem_id_t *virt_leu(void *closure) {
	jobject ret = java_method_call(closure, "virt_leu", 0);
	return (gdrr_sem_id_t*)ret;
}
static gdrr_sem_id_t *virt_lts(void *closure) {
	jobject ret = java_method_call(closure, "virt_lts", 0);
	return (gdrr_sem_id_t*)ret;
}
static gdrr_sem_id_t *virt_ltu(void *closure) {
	jobject ret = java_method_call(closure, "virt_ltu", 0);
	return (gdrr_sem_id_t*)ret;
}
static gdrr_sem_id_t *virt_t(void *closure, __word t) {
	jobject ret = java_method_call(closure, "virt_t", 1,
			java_long_create(closure, (long int)t));
	return (gdrr_sem_id_t*)ret;
}
static gdrr_sem_id_t *sem_ip(void *closure) {
	jobject ret = java_method_call(closure, "sem_ip", 0);
	return (gdrr_sem_id_t*)ret;
}
static gdrr_sem_id_t *sem_flags(void *closure) {
	jobject ret = java_method_call(closure, "sem_flags", 0);
	return (gdrr_sem_id_t*)ret;
}
static gdrr_sem_id_t *sem_mxcsr(void *closure) {
	jobject ret = java_method_call(closure, "sem_mxcsr", 0);
	return (gdrr_sem_id_t*)ret;
}
static gdrr_sem_id_t *sem_ax(void *closure) {
	jobject ret = java_method_call(closure, "sem_ax", 0);
	return (gdrr_sem_id_t*)ret;
}
static gdrr_sem_id_t *sem_bx(void *closure) {
	jobject ret = java_method_call(closure, "sem_bx", 0);
	return (gdrr_sem_id_t*)ret;
}
static gdrr_sem_id_t *sem_cx(void *closure) {
	jobject ret = java_method_call(closure, "sem_cx", 0);
	return (gdrr_sem_id_t*)ret;
}
static gdrr_sem_id_t *sem_dx(void *closure) {
	jobject ret = java_method_call(closure, "sem_dx", 0);
	return (gdrr_sem_id_t*)ret;
}
static gdrr_sem_id_t *sem_si(void *closure) {
	jobject ret = java_method_call(closure, "sem_si", 0);
	return (gdrr_sem_id_t*)ret;
}
static gdrr_sem_id_t *sem_di(void *closure) {
	jobject ret = java_method_call(closure, "sem_di", 0);
	return (gdrr_sem_id_t*)ret;
}
static gdrr_sem_id_t *sem_sp(void *closure) {
	jobject ret = java_method_call(closure, "sem_sp", 0);
	return (gdrr_sem_id_t*)ret;
}
static gdrr_sem_id_t *sem_bp(void *closure) {
	jobject ret = java_method_call(closure, "sem_bp", 0);
	return (gdrr_sem_id_t*)ret;
}
static gdrr_sem_id_t *sem_r8(void *closure) {
	jobject ret = java_method_call(closure, "sem_r8", 0);
	return (gdrr_sem_id_t*)ret;
}
static gdrr_sem_id_t *sem_r9(void *closure) {
	jobject ret = java_method_call(closure, "sem_r9", 0);
	return (gdrr_sem_id_t*)ret;
}
static gdrr_sem_id_t *sem_r10(void *closure) {
	jobject ret = java_method_call(closure, "sem_r10", 0);
	return (gdrr_sem_id_t*)ret;
}
static gdrr_sem_id_t *sem_r11(void *closure) {
	jobject ret = java_method_call(closure, "sem_r11", 0);
	return (gdrr_sem_id_t*)ret;
}
static gdrr_sem_id_t *sem_r12(void *closure) {
	jobject ret = java_method_call(closure, "sem_r12", 0);
	return (gdrr_sem_id_t*)ret;
}
static gdrr_sem_id_t *sem_r13(void *closure) {
	jobject ret = java_method_call(closure, "sem_r13", 0);
	return (gdrr_sem_id_t*)ret;
}
static gdrr_sem_id_t *sem_r14(void *closure) {
	jobject ret = java_method_call(closure, "sem_r14", 0);
	return (gdrr_sem_id_t*)ret;
}
static gdrr_sem_id_t *sem_r15(void *closure) {
	jobject ret = java_method_call(closure, "sem_r15", 0);
	return (gdrr_sem_id_t*)ret;
}
static gdrr_sem_id_t *sem_cs(void *closure) {
	jobject ret = java_method_call(closure, "sem_cs", 0);
	return (gdrr_sem_id_t*)ret;
}
static gdrr_sem_id_t *sem_ds(void *closure) {
	jobject ret = java_method_call(closure, "sem_ds", 0);
	return (gdrr_sem_id_t*)ret;
}
static gdrr_sem_id_t *sem_ss(void *closure) {
	jobject ret = java_method_call(closure, "sem_ss", 0);
	return (gdrr_sem_id_t*)ret;
}
static gdrr_sem_id_t *sem_es(void *closure) {
	jobject ret = java_method_call(closure, "sem_es", 0);
	return (gdrr_sem_id_t*)ret;
}
static gdrr_sem_id_t *sem_fs(void *closure) {
	jobject ret = java_method_call(closure, "sem_fs", 0);
	return (gdrr_sem_id_t*)ret;
}
static gdrr_sem_id_t *sem_gs(void *closure) {
	jobject ret = java_method_call(closure, "sem_gs", 0);
	return (gdrr_sem_id_t*)ret;
}
static gdrr_sem_id_t *sem_st0(void *closure) {
	jobject ret = java_method_call(closure, "sem_st0", 0);
	return (gdrr_sem_id_t*)ret;
}
static gdrr_sem_id_t *sem_st1(void *closure) {
	jobject ret = java_method_call(closure, "sem_st1", 0);
	return (gdrr_sem_id_t*)ret;
}
static gdrr_sem_id_t *sem_st2(void *closure) {
	jobject ret = java_method_call(closure, "sem_st2", 0);
	return (gdrr_sem_id_t*)ret;
}
static gdrr_sem_id_t *sem_st3(void *closure) {
	jobject ret = java_method_call(closure, "sem_st3", 0);
	return (gdrr_sem_id_t*)ret;
}
static gdrr_sem_id_t *sem_st4(void *closure) {
	jobject ret = java_method_call(closure, "sem_st4", 0);
	return (gdrr_sem_id_t*)ret;
}
static gdrr_sem_id_t *sem_st5(void *closure) {
	jobject ret = java_method_call(closure, "sem_st5", 0);
	return (gdrr_sem_id_t*)ret;
}
static gdrr_sem_id_t *sem_st6(void *closure) {
	jobject ret = java_method_call(closure, "sem_st6", 0);
	return (gdrr_sem_id_t*)ret;
}
static gdrr_sem_id_t *sem_st7(void *closure) {
	jobject ret = java_method_call(closure, "sem_st7", 0);
	return (gdrr_sem_id_t*)ret;
}
static gdrr_sem_id_t *sem_mm0(void *closure) {
	jobject ret = java_method_call(closure, "sem_mm0", 0);
	return (gdrr_sem_id_t*)ret;
}
static gdrr_sem_id_t *sem_mm1(void *closure) {
	jobject ret = java_method_call(closure, "sem_mm1", 0);
	return (gdrr_sem_id_t*)ret;
}
static gdrr_sem_id_t *sem_mm2(void *closure) {
	jobject ret = java_method_call(closure, "sem_mm2", 0);
	return (gdrr_sem_id_t*)ret;
}
static gdrr_sem_id_t *sem_mm3(void *closure) {
	jobject ret = java_method_call(closure, "sem_mm3", 0);
	return (gdrr_sem_id_t*)ret;
}
static gdrr_sem_id_t *sem_mm4(void *closure) {
	jobject ret = java_method_call(closure, "sem_mm4", 0);
	return (gdrr_sem_id_t*)ret;
}
static gdrr_sem_id_t *sem_mm5(void *closure) {
	jobject ret = java_method_call(closure, "sem_mm5", 0);
	return (gdrr_sem_id_t*)ret;
}
static gdrr_sem_id_t *sem_mm6(void *closure) {
	jobject ret = java_method_call(closure, "sem_mm6", 0);
	return (gdrr_sem_id_t*)ret;
}
static gdrr_sem_id_t *sem_mm7(void *closure) {
	jobject ret = java_method_call(closure, "sem_mm7", 0);
	return (gdrr_sem_id_t*)ret;
}
static gdrr_sem_id_t *sem_xmm0(void *closure) {
	jobject ret = java_method_call(closure, "sem_xmm0", 0);
	return (gdrr_sem_id_t*)ret;
}
static gdrr_sem_id_t *sem_xmm1(void *closure) {
	jobject ret = java_method_call(closure, "sem_xmm1", 0);
	return (gdrr_sem_id_t*)ret;
}
static gdrr_sem_id_t *sem_xmm2(void *closure) {
	jobject ret = java_method_call(closure, "sem_xmm2", 0);
	return (gdrr_sem_id_t*)ret;
}
static gdrr_sem_id_t *sem_xmm3(void *closure) {
	jobject ret = java_method_call(closure, "sem_xmm3", 0);
	return (gdrr_sem_id_t*)ret;
}
static gdrr_sem_id_t *sem_xmm4(void *closure) {
	jobject ret = java_method_call(closure, "sem_xmm4", 0);
	return (gdrr_sem_id_t*)ret;
}
static gdrr_sem_id_t *sem_xmm5(void *closure) {
	jobject ret = java_method_call(closure, "sem_xmm5", 0);
	return (gdrr_sem_id_t*)ret;
}
static gdrr_sem_id_t *sem_xmm6(void *closure) {
	jobject ret = java_method_call(closure, "sem_xmm6", 0);
	return (gdrr_sem_id_t*)ret;
}
static gdrr_sem_id_t *sem_xmm7(void *closure) {
	jobject ret = java_method_call(closure, "sem_xmm7", 0);
	return (gdrr_sem_id_t*)ret;
}
static gdrr_sem_id_t *sem_xmm8(void *closure) {
	jobject ret = java_method_call(closure, "sem_xmm8", 0);
	return (gdrr_sem_id_t*)ret;
}
static gdrr_sem_id_t *sem_xmm9(void *closure) {
	jobject ret = java_method_call(closure, "sem_xmm9", 0);
	return (gdrr_sem_id_t*)ret;
}
static gdrr_sem_id_t *sem_xmm10(void *closure) {
	jobject ret = java_method_call(closure, "sem_xmm10", 0);
	return (gdrr_sem_id_t*)ret;
}
static gdrr_sem_id_t *sem_xmm11(void *closure) {
	jobject ret = java_method_call(closure, "sem_xmm11", 0);
	return (gdrr_sem_id_t*)ret;
}
static gdrr_sem_id_t *sem_xmm12(void *closure) {
	jobject ret = java_method_call(closure, "sem_xmm12", 0);
	return (gdrr_sem_id_t*)ret;
}
static gdrr_sem_id_t *sem_xmm13(void *closure) {
	jobject ret = java_method_call(closure, "sem_xmm13", 0);
	return (gdrr_sem_id_t*)ret;
}
static gdrr_sem_id_t *sem_xmm14(void *closure) {
	jobject ret = java_method_call(closure, "sem_xmm14", 0);
	return (gdrr_sem_id_t*)ret;
}
static gdrr_sem_id_t *sem_xmm15(void *closure) {
	jobject ret = java_method_call(closure, "sem_xmm15", 0);
	return (gdrr_sem_id_t*)ret;
}

// sem_address
static gdrr_sem_address_t *sem_address(void *closure, __word size,
		gdrr_sem_linear_t *address) {
	jobject ret = java_method_call(closure, "sem_address", 2,
			java_long_create(closure, (long int)size), (jobject)address);
	return (gdrr_sem_var_t*)ret;
}

// sem_var
static gdrr_sem_var_t *sem_var(void *closure, gdrr_sem_id_t *id, __word offset) {
	jobject ret = java_method_call(closure, "sem_var", 2, (jobject)id,
			java_long_create(closure, (long int)offset));
	return (gdrr_sem_var_t*)ret;
}

// sem_linear
static gdrr_sem_linear_t *sem_lin_var(void *closure, gdrr_sem_var_t *this) {
	jobject ret = java_method_call(closure, "sem_lin_var", 1, (jobject)this);
	return (gdrr_sem_linear_t*)ret;
}
static gdrr_sem_linear_t *sem_lin_imm(void *closure, __word imm) {
	jobject ret = java_method_call(closure, "sem_lin_imm", 1,
			java_long_create(closure, (long int)imm));
	return (gdrr_sem_linear_t*)ret;
}
static gdrr_sem_linear_t *sem_lin_add(void *closure, gdrr_sem_linear_t *opnd1,
		gdrr_sem_linear_t *opnd2) {
	jobject ret = java_method_call(closure, "sem_lin_add", 2, (jobject)opnd1,
			(jobject)opnd2);
	return (gdrr_sem_linear_t*)ret;
}
static gdrr_sem_linear_t *sem_lin_sub(void *closure, gdrr_sem_linear_t *opnd1,
		gdrr_sem_linear_t *opnd2) {
	jobject ret = java_method_call(closure, "sem_lin_sub", 2, (jobject)opnd1,
			(jobject)opnd2);
	return (gdrr_sem_linear_t*)ret;
}
static gdrr_sem_linear_t *sem_lin_scale(void *closure, __word imm,
		gdrr_sem_linear_t *opnd) {
	jobject ret = java_method_call(closure, "sem_lin_scale", 2,
			java_long_create(closure, (long int)imm), (jobject)opnd);
	return (gdrr_sem_linear_t*)ret;
}

// sem_op
static gdrr_sem_op_t *sem_lin(void *closure, __word size,
		gdrr_sem_linear_t *opnd1) {
	jobject ret = java_method_call(closure, "sem_lin", 2,
			java_long_create(closure, (long int)size), (jobject)opnd1);
	return (gdrr_sem_op_t*)ret;
}
static gdrr_sem_op_t *sem_mul(void *closure, __word size,
		gdrr_sem_linear_t *opnd1, gdrr_sem_linear_t *opnd2) {
	jobject ret = java_method_call(closure, "sem_mul", 3,
			java_long_create(closure, (long int)size), (jobject)opnd1,
			(jobject)opnd2);
	return (gdrr_sem_op_t*)ret;
}
static gdrr_sem_op_t *sem_div(void *closure, __word size,
		gdrr_sem_linear_t *opnd1, gdrr_sem_linear_t *opnd2) {
	jobject ret = java_method_call(closure, "sem_div", 3,
			java_long_create(closure, (long int)size), (jobject)opnd1,
			(jobject)opnd2);
	return (gdrr_sem_op_t*)ret;
}
static gdrr_sem_op_t *sem_divs(void *closure, __word size,
		gdrr_sem_linear_t *opnd1, gdrr_sem_linear_t *opnd2) {
	jobject ret = java_method_call(closure, "sem_divs", 3,
			java_long_create(closure, (long int)size), (jobject)opnd1,
			(jobject)opnd2);
	return (gdrr_sem_op_t*)ret;
}
static gdrr_sem_op_t *sem_mod(void *closure, __word size,
		gdrr_sem_linear_t *opnd1, gdrr_sem_linear_t *opnd2) {
	jobject ret = java_method_call(closure, "sem_mod", 3,
			java_long_create(closure, (long int)size), (jobject)opnd1,
			(jobject)opnd2);
	return (gdrr_sem_op_t*)ret;
}
static gdrr_sem_op_t *sem_shl(void *closure, __word size,
		gdrr_sem_linear_t *opnd1, gdrr_sem_linear_t *opnd2) {
	jobject ret = java_method_call(closure, "sem_shl", 3,
			java_long_create(closure, (long int)size), (jobject)opnd1,
			(jobject)opnd2);
	return (gdrr_sem_op_t*)ret;
}
static gdrr_sem_op_t *sem_shr(void *closure, __word size,
		gdrr_sem_linear_t *opnd1, gdrr_sem_linear_t *opnd2) {
	jobject ret = java_method_call(closure, "sem_shr", 3,
			java_long_create(closure, (long int)size), (jobject)opnd1,
			(jobject)opnd2);
	return (gdrr_sem_op_t*)ret;
}
static gdrr_sem_op_t *sem_shrs(void *closure, __word size,
		gdrr_sem_linear_t *opnd1, gdrr_sem_linear_t *opnd2) {
	jobject ret = java_method_call(closure, "sem_shrs", 3,
			java_long_create(closure, (long int)size), (jobject)opnd1,
			(jobject)opnd2);
	return (gdrr_sem_op_t*)ret;
}
static gdrr_sem_op_t *sem_and(void *closure, __word size,
		gdrr_sem_linear_t *opnd1, gdrr_sem_linear_t *opnd2) {
	jobject ret = java_method_call(closure, "sem_and", 3,
			java_long_create(closure, (long int)size), (jobject)opnd1,
			(jobject)opnd2);
	return (gdrr_sem_op_t*)ret;
}
static gdrr_sem_op_t *sem_or(void *closure, __word size,
		gdrr_sem_linear_t *opnd1, gdrr_sem_linear_t *opnd2) {
	jobject ret = java_method_call(closure, "sem_or", 3,
			java_long_create(closure, (long int)size), (jobject)opnd1,
			(jobject)opnd2);
	return (gdrr_sem_op_t*)ret;
}
static gdrr_sem_op_t *sem_xor(void *closure, __word size,
		gdrr_sem_linear_t *opnd1, gdrr_sem_linear_t *opnd2) {
	jobject ret = java_method_call(closure, "sem_xor", 3,
			java_long_create(closure, (long int)size), (jobject)opnd1,
			(jobject)opnd2);
	return (gdrr_sem_op_t*)ret;
}
static gdrr_sem_op_t *sem_sx(void *closure, __word size, __word fromsize,
		gdrr_sem_linear_t *opnd1) {
	jobject ret = java_method_call(closure, "sem_sx", 3,
			java_long_create(closure, (long int)size),
			java_long_create(closure, (long int)fromsize), (jobject)opnd1);
	return (gdrr_sem_op_t*)ret;
}
static gdrr_sem_op_t *sem_zx(void *closure, __word size, __word fromsize,
		gdrr_sem_linear_t *opnd1) {
	jobject ret = java_method_call(closure, "sem_zx", 3,
			java_long_create(closure, (long int)size),
			java_long_create(closure, (long int)fromsize), (jobject)opnd1);
	return (gdrr_sem_op_t*)ret;
}
static gdrr_sem_op_t *sem_cmpeq(void *closure, __word size,
		gdrr_sem_linear_t *opnd1, gdrr_sem_linear_t *opnd2) {
	jobject ret = java_method_call(closure, "sem_cmpeq", 3,
			java_long_create(closure, (long int)size), (jobject)opnd1,
			(jobject)opnd2);
	return (gdrr_sem_op_t*)ret;
}
static gdrr_sem_op_t *sem_cmpneq(void *closure, __word size,
		gdrr_sem_linear_t *opnd1, gdrr_sem_linear_t *opnd2) {
	jobject ret = java_method_call(closure, "sem_cmpneq", 3,
			java_long_create(closure, (long int)size), (jobject)opnd1,
			(jobject)opnd2);
	return (gdrr_sem_op_t*)ret;
}
static gdrr_sem_op_t *sem_cmples(void *closure, __word size,
		gdrr_sem_linear_t *opnd1, gdrr_sem_linear_t *opnd2) {
	jobject ret = java_method_call(closure, "sem_cmples", 3,
			java_long_create(closure, (long int)size), (jobject)opnd1,
			(jobject)opnd2);
	return (gdrr_sem_op_t*)ret;
}
static gdrr_sem_op_t *sem_cmpleu(void *closure, __word size,
		gdrr_sem_linear_t *opnd1, gdrr_sem_linear_t *opnd2) {
	jobject ret = java_method_call(closure, "sem_cmpleu", 3,
			java_long_create(closure, (long int)size), (jobject)opnd1,
			(jobject)opnd2);
	return (gdrr_sem_op_t*)ret;
}
static gdrr_sem_op_t *sem_cmplts(void *closure, __word size,
		gdrr_sem_linear_t *opnd1, gdrr_sem_linear_t *opnd2) {
	jobject ret = java_method_call(closure, "sem_cmplts", 3,
			java_long_create(closure, (long int)size), (jobject)opnd1,
			(jobject)opnd2);
	return (gdrr_sem_op_t*)ret;
}
static gdrr_sem_op_t *sem_cmpltu(void *closure, __word size,
		gdrr_sem_linear_t *opnd1, gdrr_sem_linear_t *opnd2) {
	jobject ret = java_method_call(closure, "sem_cmpltu", 3,
			java_long_create(closure, (long int)size), (jobject)opnd1,
			(jobject)opnd2);
	return (gdrr_sem_op_t*)ret;
}
static gdrr_sem_op_t *sem_arb(void *closure, __word size) {
	jobject ret = java_method_call(closure, "sem_arb", 1,
			java_long_create(closure, (long int)size));
	return (gdrr_sem_op_t*)ret;
}

// sem_branch_hint
static gdrr_sem_branch_hint *hint_jump(void *closure) {
	jobject ret = java_method_call(closure, "hint_jump", 0);
	return (gdrr_sem_branch_hint*)ret;
}
static gdrr_sem_branch_hint *hint_call(void *closure) {
	jobject ret = java_method_call(closure, "hint_call", 0);
	return (gdrr_sem_branch_hint*)ret;
}
static gdrr_sem_branch_hint *hint_ret(void *closure) {
	jobject ret = java_method_call(closure, "hint_ret", 0);
	return (gdrr_sem_branch_hint*)ret;
}

// sem_stmt
static gdrr_sem_stmt_t *sem_assign(void *closure, gdrr_sem_var_t *lhs,
		gdrr_sem_op_t *rhs) {
	jobject ret = java_method_call(closure, "sem_assign", 2, (jobject)lhs,
			(jobject)rhs);
	return (gdrr_sem_stmt_t*)ret;
}
static gdrr_sem_stmt_t *sem_load(void *closure, gdrr_sem_var_t *lhs,
		__word size, gdrr_sem_address_t *address) {
	jobject ret = java_method_call(closure, "sem_load", 3, (jobject)lhs,
			java_long_create(closure, (long)size), (jobject)address);
	return (gdrr_sem_stmt_t*)ret;
}
static gdrr_sem_stmt_t *sem_store(void *closure, gdrr_sem_var_t *lhs,
		gdrr_sem_op_t *rhs) {
	jobject ret = java_method_call(closure, "sem_store", 2, (jobject)lhs,
			(jobject)rhs);
	return (gdrr_sem_stmt_t*)ret;
}
static gdrr_sem_stmt_t *sem_ite(void *closure, gdrr_sem_linear_t *cond,
		gdrr_sem_stmts_t *then_branch, gdrr_sem_stmts_t *else_branch) {
	jobject ret = java_method_call(closure, "sem_ite", 3, (jobject)cond,
			(jobject)then_branch, (jobject)else_branch);
	return (gdrr_sem_stmt_t*)ret;
}
static gdrr_sem_stmt_t *sem_while(void *closure, gdrr_sem_linear_t *cond,
		gdrr_sem_stmts_t *body) {
	jobject ret = java_method_call(closure, "sem_while", 2, (jobject)cond,
			(jobject)body);
	return (gdrr_sem_stmt_t*)ret;
}
static gdrr_sem_stmt_t *sem_cbranch(void *closure, gdrr_sem_linear_t *cond,
		gdrr_sem_address_t *target_true, gdrr_sem_address_t *target_false) {
	jobject ret = java_method_call(closure, "sem_cbranch", 3, (jobject)cond,
			(jobject)target_true, (jobject)target_false);
	return (gdrr_sem_stmt_t*)ret;
}
static gdrr_sem_stmt_t *sem_branch(void *closure,
		gdrr_sem_branch_hint *branch_hint, gdrr_sem_address_t *target) {
	jobject ret = java_method_call(closure, "sem_branch", 2, (jobject)branch_hint,
			(jobject)target);
	return (gdrr_sem_stmt_t*)ret;
}

// sem_stmts
static gdrr_sem_stmts_t *list_next(void *closure, gdrr_sem_stmt_t *next,
		gdrr_sem_stmts_t *list) {
	jobject ret = java_method_call(closure, "list_next", 2, (jobject)next,
			(jobject)list);
	return (gdrr_sem_stmts_t*)ret;
}
static gdrr_sem_stmts_t *list_init(void *closure) {
	jobject ret = java_method_call(closure, "list_init", 0);
	return (gdrr_sem_stmts_t*)ret;
}

JNIEXPORT
jobject
JNICALL Java_rnati_NativeInterface_decodeAndTranslateNative(JNIEnv *env,
		jobject obj, jbyteArray input) {
	if(input == NULL) {
		jclass exp = (*env)->FindClass(env, "java/lang/IllegalArgumentException");
		(*env)->ThrowNew(env, exp, "Input must not be null.");
		return NULL;
	}

	size_t length = (*env)->GetArrayLength(env, input);
	__char *bytes = (char*)(*env)->GetByteArrayElements(env, input, 0);

	__obj state = __createState(bytes, length, 0, 0);
	__obj insn = __runMonadicNoArg(__decode__, &state);

	if(___isNil(insn)) {
		jclass exp = (*env)->FindClass(env, "rnati/ReilDecodeException");
		(*env)->ThrowNew(env, exp, "Decode failed.");
		return NULL;
	} else {
		//__pretty(__pretty__, insn, fmt, 1024);
//		puts(fmt);
//		printf("---------------------------\n");

		__obj r = __runMonadicOneArg(__translate__, &state, insn);

		if(___isNil(r)) {
			jclass exp = (*env)->FindClass(env, "rnati/RReilTranslateException");
			(*env)->ThrowNew(env, exp, "Translate failed.");
			return NULL;
		} else {
//			__pretty(__rreil_pretty__, r, fmt, 2048);
//			printf("---------------------------\n");
//			puts(fmt);

			struct gdrr_config config;

			config.callbacks.sem_id.virt_eq = &virt_eq;
			config.callbacks.sem_id.virt_neq = &virt_neq;
			config.callbacks.sem_id.virt_les = &virt_les;
			config.callbacks.sem_id.virt_leu = &virt_leu;
			config.callbacks.sem_id.virt_lts = &virt_lts;
			config.callbacks.sem_id.virt_ltu = &virt_ltu;
			config.callbacks.sem_id.virt_t = &virt_t;
			config.callbacks.arch.x86.sem_id.sem_ip = &sem_ip;
			config.callbacks.arch.x86.sem_id.sem_flags = &sem_flags;
			config.callbacks.arch.x86.sem_id.sem_mxcsr = &sem_mxcsr;
			config.callbacks.arch.x86.sem_id.sem_ax = &sem_ax;
			config.callbacks.arch.x86.sem_id.sem_bx = &sem_bx;
			config.callbacks.arch.x86.sem_id.sem_cx = &sem_cx;
			config.callbacks.arch.x86.sem_id.sem_dx = &sem_dx;
			config.callbacks.arch.x86.sem_id.sem_si = &sem_si;
			config.callbacks.arch.x86.sem_id.sem_di = &sem_di;
			config.callbacks.arch.x86.sem_id.sem_sp = &sem_sp;
			config.callbacks.arch.x86.sem_id.sem_bp = &sem_bp;
			config.callbacks.arch.x86.sem_id.sem_r8 = &sem_r8;
			config.callbacks.arch.x86.sem_id.sem_r9 = &sem_r9;
			config.callbacks.arch.x86.sem_id.sem_r10 = &sem_r10;
			config.callbacks.arch.x86.sem_id.sem_r11 = &sem_r11;
			config.callbacks.arch.x86.sem_id.sem_r12 = &sem_r12;
			config.callbacks.arch.x86.sem_id.sem_r13 = &sem_r13;
			config.callbacks.arch.x86.sem_id.sem_r14 = &sem_r14;
			config.callbacks.arch.x86.sem_id.sem_r15 = &sem_r15;
			config.callbacks.arch.x86.sem_id.sem_cs = &sem_cs;
			config.callbacks.arch.x86.sem_id.sem_ds = &sem_ds;
			config.callbacks.arch.x86.sem_id.sem_ss = &sem_ss;
			config.callbacks.arch.x86.sem_id.sem_es = &sem_es;
			config.callbacks.arch.x86.sem_id.sem_fs = &sem_fs;
			config.callbacks.arch.x86.sem_id.sem_gs = &sem_gs;
			config.callbacks.arch.x86.sem_id.sem_st0 = &sem_st0;
			config.callbacks.arch.x86.sem_id.sem_st1 = &sem_st1;
			config.callbacks.arch.x86.sem_id.sem_st2 = &sem_st2;
			config.callbacks.arch.x86.sem_id.sem_st3 = &sem_st3;
			config.callbacks.arch.x86.sem_id.sem_st4 = &sem_st4;
			config.callbacks.arch.x86.sem_id.sem_st5 = &sem_st5;
			config.callbacks.arch.x86.sem_id.sem_st6 = &sem_st6;
			config.callbacks.arch.x86.sem_id.sem_st7 = &sem_st7;
			config.callbacks.arch.x86.sem_id.sem_mm0 = &sem_mm0;
			config.callbacks.arch.x86.sem_id.sem_mm1 = &sem_mm1;
			config.callbacks.arch.x86.sem_id.sem_mm2 = &sem_mm2;
			config.callbacks.arch.x86.sem_id.sem_mm3 = &sem_mm3;
			config.callbacks.arch.x86.sem_id.sem_mm4 = &sem_mm4;
			config.callbacks.arch.x86.sem_id.sem_mm5 = &sem_mm5;
			config.callbacks.arch.x86.sem_id.sem_mm6 = &sem_mm6;
			config.callbacks.arch.x86.sem_id.sem_mm7 = &sem_mm7;
			config.callbacks.arch.x86.sem_id.sem_xmm0 = &sem_xmm0;
			config.callbacks.arch.x86.sem_id.sem_xmm1 = &sem_xmm1;
			config.callbacks.arch.x86.sem_id.sem_xmm2 = &sem_xmm2;
			config.callbacks.arch.x86.sem_id.sem_xmm3 = &sem_xmm3;
			config.callbacks.arch.x86.sem_id.sem_xmm4 = &sem_xmm4;
			config.callbacks.arch.x86.sem_id.sem_xmm5 = &sem_xmm5;
			config.callbacks.arch.x86.sem_id.sem_xmm6 = &sem_xmm6;
			config.callbacks.arch.x86.sem_id.sem_xmm7 = &sem_xmm7;
			config.callbacks.arch.x86.sem_id.sem_xmm8 = &sem_xmm8;
			config.callbacks.arch.x86.sem_id.sem_xmm9 = &sem_xmm9;
			config.callbacks.arch.x86.sem_id.sem_xmm10 = &sem_xmm10;
			config.callbacks.arch.x86.sem_id.sem_xmm11 = &sem_xmm11;
			config.callbacks.arch.x86.sem_id.sem_xmm12 = &sem_xmm12;
			config.callbacks.arch.x86.sem_id.sem_xmm13 = &sem_xmm13;
			config.callbacks.arch.x86.sem_id.sem_xmm14 = &sem_xmm14;
			config.callbacks.arch.x86.sem_id.sem_xmm15 = &sem_xmm15;
			//%s/gdrr_sem_id_t .(.\(.*\))(void .closure);/config.callbacks.arch.x86.sem_id.\1 = \&\1;/g

			config.callbacks.sem_address.sem_address = &sem_address;

			config.callbacks.sem_var.sem_var = &sem_var;

			config.callbacks.sem_linear.sem_lin_var = &sem_lin_var;
			config.callbacks.sem_linear.sem_lin_imm = &sem_lin_imm;
			config.callbacks.sem_linear.sem_lin_add = &sem_lin_add;
			config.callbacks.sem_linear.sem_lin_sub = &sem_lin_sub;
			config.callbacks.sem_linear.sem_lin_scale = &sem_lin_scale;

			config.callbacks.sem_op.sem_lin = &sem_lin;
			config.callbacks.sem_op.sem_mul = &sem_mul;
			config.callbacks.sem_op.sem_div = &sem_div;
			config.callbacks.sem_op.sem_divs = &sem_divs;
			config.callbacks.sem_op.sem_mod = &sem_mod;
			config.callbacks.sem_op.sem_shl = &sem_shl;
			config.callbacks.sem_op.sem_shr = &sem_shr;
			config.callbacks.sem_op.sem_shrs = &sem_shrs;
			config.callbacks.sem_op.sem_and = &sem_and;
			config.callbacks.sem_op.sem_or = &sem_or;
			config.callbacks.sem_op.sem_xor = &sem_xor;
			config.callbacks.sem_op.sem_sx = &sem_sx;
			config.callbacks.sem_op.sem_zx = &sem_zx;
			config.callbacks.sem_op.sem_cmpeq = &sem_cmpeq;
			config.callbacks.sem_op.sem_cmpneq = &sem_cmpneq;
			config.callbacks.sem_op.sem_cmples = &sem_cmples;
			config.callbacks.sem_op.sem_cmpleu = &sem_cmpleu;
			config.callbacks.sem_op.sem_cmplts = &sem_cmplts;
			config.callbacks.sem_op.sem_cmpltu = &sem_cmpltu;
			config.callbacks.sem_op.sem_arb = &sem_arb;

			config.callbacks.sem_branch_hint.hint_jump = &hint_jump;
			config.callbacks.sem_branch_hint.hint_call = &hint_call;
			config.callbacks.sem_branch_hint.hint_ret = &hint_ret;

			config.callbacks.sem_stmt.sem_assign = &sem_assign;
			config.callbacks.sem_stmt.sem_load = &sem_load;
			config.callbacks.sem_stmt.sem_store = &sem_store;
			config.callbacks.sem_stmt.sem_ite = &sem_ite;
			config.callbacks.sem_stmt.sem_while = &sem_while;
			config.callbacks.sem_stmt.sem_cbranch = &sem_cbranch;
			config.callbacks.sem_stmt.sem_branch = &sem_branch;

			config.callbacks.sem_stmts_list.list_init = &list_init;
			config.callbacks.sem_stmts_list.list_next = &list_next;
			config.gdrr_config_stmts_handling = GDRR_CONFIG_STMTS_HANDLING_LIST;

			struct closure cls;
			cls.env = env;
			cls.obj = obj;
			config.closure = &cls;

			return gdrr_convert(r, &config);
		}
	}
}