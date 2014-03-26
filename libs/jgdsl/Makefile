MLTK=../..
CC=gcc
#CC=clang
LIBDS=-L$(MLTK)/lib
LIBS=-lgdsl-multiplex
LIBFLAGS=$(LIBDS) $(LIBS)
INCDS=-Iinclude -I$(MLTK)/include -I/usr/lib/jvm/java-7-openjdk-amd64/include

DEFINES=-DRELAXEDFATAL
ifdef GDSL_X86
DEFINES+=-DGDSL_X86
endif

CFLAGS=-std=c11 -g3 -fPIC -shared -pedantic -Wall -Wfatal-errors $(DEFINES) $(INCDS)

LIBRARY=libjgdsl.so
JAR_SRC=jgdsl-src.jar
JAR=jgdsl.jar

C_SOURCES=src/gdsl_rreil_BuilderBackend.c src/gdsl_Gdsl.c src/gdsl_decoder_Instruction.c src/gdsl_BareFrontend.c src/gdsl_ListFrontend.c

all: pre-build $(LIBRARY) $(JAR_SRC) $(JAR)

SPRE=src
BPRE=build

BDIRS=$(BPRE)
pre-build:
	mkdir -p $(BDIRS)

$(LIBRARY): $(C_SOURCES)
	$(CC) $(CFLAGS) $(C_SOURCES) $(LIBFLAGS) -o $@
#	$(CC) $(CFLAGS) -Wl,-soname,$(LIBRARY) $< $(LIBFLAGS) -o $@

JSOURCES=$(shell find src/ -type f -name '*.java')
#JSOURCES=$(wildcard src/**/*.java)

$(JAR_SRC): $(JSOURCES)
	jar -cf $@ $(JSOURCES:$(SPRE)/%.java=-C $(SPRE) %.java)

$(JAR): $(JSOURCES)
	javac $(JSOURCES) -d $(BPRE)/
	jar -cf $@ $(JSOURCES:$(SPRE)/%.java=-C $(BPRE) %.class)

clean:
	rm -rf $(BDIRS)/ $(LIBRARY) $(JAR)