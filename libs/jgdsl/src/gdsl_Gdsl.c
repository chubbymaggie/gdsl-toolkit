/*
 * gdsl_Gdsl.c
 *
 *  Created on: Feb 13, 2014
 *      Author: jucs
 */

#include <stdlib.h>
#include <stdio.h>
#include <stdint.h>
#include <jni.h>
#include <gdsl_generic.h>
#include <gdsl_multiplex.h>
#include "gdsl_Gdsl.h"

#define THROW_RUNTIME(RET, MSG) {\
		jclass exp = (*env)->FindClass(env, "java/lang/RuntimeException");\
		(*env)->ThrowNew(env, exp, MSG);\
		return RET;\
}

#define THROW_GDSL_ERROR(RET) {\
		jclass exp = (*env)->FindClass(env, "gdsl/GdslException");\
		(*env)->ThrowNew(env, exp, frontend->generic.get_error_message(state));\
		return RET;\
}

static jobjectArray get_frontends_with_descs(JNIEnv *env, struct frontend_desc *descs, size_t descs_length) {
  jclass Gdsl_ListFrontend = (*env)->FindClass(env, "gdsl/ListFrontend");

  jobjectArray jfrontends = (*env)->NewObjectArray(env, descs_length, Gdsl_ListFrontend, (*env)->NewStringUTF(env, ""));

  for(size_t i = 0; i < descs_length; ++i) {
    jstring name = (*env)->NewStringUTF(env, descs[i].name);
    jstring ext = (*env)->NewStringUTF(env, descs[i].ext);

    jmethodID cons = (*env)->GetMethodID(env, Gdsl_ListFrontend, "<init>", "(Ljava/lang/String;Ljava/lang/String;)V");
    jobject frontend = (*env)->NewObject(env, Gdsl_ListFrontend, cons, name, ext);

    (*env)->SetObjectArrayElement(env, jfrontends, i, frontend);
  }

  gdsl_multiplex_descs_free(descs, descs_length);

  return jfrontends;
}

JNIEXPORT jobjectArray JNICALL Java_gdsl_Gdsl_getFrontendsNative(JNIEnv *env, jclass cls) {
  struct frontend_desc *descs = NULL;
  size_t descs_length = gdsl_multiplex_frontends_list(&descs);

  return get_frontends_with_descs(env, descs, descs_length);
}

JNIEXPORT jobjectArray JNICALL Java_gdsl_Gdsl_getFrontendsNativeWithBase(JNIEnv *env, jclass cls, jstring jbase) {
  const char *base = (*env)->GetStringUTFChars(env, jbase, 0);
  struct frontend_desc *descs = NULL;
  size_t descs_length = gdsl_multiplex_frontends_list_with_base(&descs, base);
  jobjectArray result = get_frontends_with_descs(env, descs, descs_length);
  (*env)->ReleaseStringUTFChars(env, jbase, base);
  return result;
}

JNIEXPORT jlong JNICALL Java_gdsl_Gdsl_init(JNIEnv *env, jobject this, jlong frontendPtr) {
  struct frontend *frontend = (struct frontend*)frontendPtr;

  return (jlong)frontend->generic.init();
}

JNIEXPORT void JNICALL Java_gdsl_Gdsl_setCode(JNIEnv *env, jobject this, jlong frontendPtr, jlong gdslStatePtr,
    jobject byteBuffer, jlong offset, jlong base) {
  jclass java_Nio_ByteBuffer = (*env)->FindClass(env, "java/nio/ByteBuffer");
  jmethodID capacity = (*env)->GetMethodID(env, java_Nio_ByteBuffer, "capacity", "()I");

  jint size = (*env)->CallIntMethod(env, byteBuffer, capacity);
  jbyte *buffer = (*env)->GetDirectBufferAddress(env, byteBuffer);

  struct frontend *frontend = (struct frontend*)frontendPtr;
  state_t state = (state_t)gdslStatePtr;

  if(setjmp(*frontend->generic.err_tgt(state)))
  THROW_GDSL_ERROR()

  frontend->generic.set_code(state, (unsigned char*)(buffer + offset), (uint64_t)(size - offset), (uint64_t)base);
}

static obj_t decode_one(JNIEnv *env, jobject this, jlong frontendPtr, jlong gdslStatePtr, int_t decode_config) {
  struct frontend *frontend = (struct frontend*)frontendPtr;
  state_t state = (state_t)gdslStatePtr;

  if(setjmp(*frontend->generic.err_tgt(state))) {
    jclass exp = (*env)->FindClass(env, "gdsl/decoder/GdslDecodeException");
    (*env)->ThrowNew(env, exp, "Decode failed");
    return 0;
  }

  obj_t insn = frontend->decoder.decode(state, decode_config);
  return insn;
}

JNIEXPORT jlong JNICALL Java_gdsl_Gdsl_decodeOne(JNIEnv *env, jobject this, jlong frontendPtr, jlong gdslStatePtr) {
  struct frontend *frontend = (struct frontend*)frontendPtr;
  state_t state = (state_t)gdslStatePtr;

  return (jlong)decode_one(env, this, frontendPtr, gdslStatePtr, frontend->decoder.config_default(state));
}

JNIEXPORT jlong JNICALL Java_gdsl_Gdsl_decodeOneWithConfig(JNIEnv *env, jobject this, jlong frontendPtr,
    jlong gdslStatePtr, jlong decodeConfig) {
  return (jlong)decode_one(env, this, frontendPtr, gdslStatePtr, decodeConfig);
}

JNIEXPORT jlong JNICALL Java_gdsl_Gdsl_getIpOffset(JNIEnv *env, jobject this, jlong frontendPtr, jlong gdslStatePtr) {
  struct frontend *frontend = (struct frontend*)frontendPtr;
  state_t state = (state_t)gdslStatePtr;

  if(setjmp(*frontend->generic.err_tgt(state)))
  THROW_GDSL_ERROR(0)

  return (jlong)frontend->generic.get_ip(state);
}

JNIEXPORT void JNICALL Java_gdsl_Gdsl_resetHeap(JNIEnv *env, jobject this, jlong frontendPtr, jlong gdslStatePtr) {
  struct frontend *frontend = (struct frontend*)frontendPtr;
  state_t state = (state_t)gdslStatePtr;

//	printf("Resetting heap...\n");
//	fflush(stdout);

  if(setjmp(*frontend->generic.err_tgt(state)))
  THROW_GDSL_ERROR()

  frontend->generic.reset_heap(state);
}

JNIEXPORT void JNICALL Java_gdsl_Gdsl_destroy(JNIEnv *env, jobject this, jlong frontendPtr, jlong gdslStatePtr) {
  struct frontend *frontend = (struct frontend*)frontendPtr;
  state_t state = (state_t)gdslStatePtr;

//	printf("Destroying Gdsl...\n");
//	fflush(stdout);

  if(setjmp(*frontend->generic.err_tgt(state)))
  THROW_GDSL_ERROR()

  frontend->generic.destroy(state);
}
