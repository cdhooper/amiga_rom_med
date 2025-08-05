#
# Makefile to build AmigaOS/68k tools using Bebbo's GCC cross-compiler.
#

PROGROM	 := med.rom
PROG     := rom_med

OBJDIR   := objs
MED_SRCS := med_cmds.c mem_access.c med_cmdline.c med_readline.c db_disasm.c
SRCS     := main.c autoconfig.c cache.c keyboard.c pcmds.c \
            printf.c reset.c scanf.c screen.c serial.c \
            sprite.c strtoll.c strtoull.c timer.c util.c \
	    vectors.c $(MED_SRCS)
#SRCS   += sm_msg.c cpu_control.c sm_msg_core.c

OBJS    := $(SRCS:%.c=$(OBJDIR)/%.o)
MED_OBJS := $(MED_SRCS:%.c=$(OBJDIR)/%.o)
DEHUNK   := $(OBJDIR)/dehunk

CC      := m68k-amigaos-gcc
LD      := m68k-amigaos-ld
DD	:= dd
CFLAGS  := -Wall -Wextra -Wno-pointer-sign -Wno-format -Wno-strict-aliasing
CFLAGS  += -Wno-sign-compare -fomit-frame-pointer
CFLAGS  += -DROMFS -DEMBEDDED_CMD -fbaserel -resident -mcpu=68060
CFLAGS  += -DRAM_BASE=0x00000000
#CFLAGS  += -DRAM_BASE=0x07e00000
#LDFLAGS := -nostartfiles -nodefaultlibs -nostdlib
#LDFLAGS += -lgcc -lc -lamiga -Xlinker --verbose -Trom.ld -mcrt=clib2 -fbaserel
LDFLAGS := --nostdlib \
	   --amiga-databss-together \
	   -L/opt/amiga13/lib \
	   -L/opt/amiga13/lib/gcc \
	   -L/opt/amiga13/lib/gcc/m68k-amigaos/13.2.0 \
	   -L/opt/amiga13/lib/gcc/m68k-amigaos/13.2.0/libb \
	   -L/opt/amiga13/m68k-amigaos/lib \
	   -L/opt/amiga13/m68k-amigaos/lib/libb \

#	   -L/opt/amiga13/m68k-amigaos/clib2/lib \
#	   -L/opt/amiga13/m68k-amigaos/clib2/lib/libb
LDFLAGS += -lgcc -lc --verbose
#	   -L/opt/amiga13/m68k-amigaos/libnix/lib \
#	   -L/opt/amiga13/m68k-amigaos/libnix/lib/libb
#LDFLAGS += -lgcc -lnix4 --verbose

# const char RomID[] = "ROM MED 0.1 (2025-01-09)\n";
PROGVER := rom_med_$(shell awk '/const char RomID/{print $$7}' main.c)

NDK_PATH := /opt/amiga/m68k-amigaos/ndk-include
VASM     := vasmm68k_mot

NOW  := $(shell date +%s)
ifeq ($(OS),Darwin)
DATE := $(shell date -j -f %s $(NOW)  '+%Y-%m-%d')
TIME := $(shell date -j -f %s $(NOW)  '+%H:%M:%S')
else
DATE := $(shell date -d "@$(NOW)" '+%Y-%m-%d')
TIME := $(shell date -d "@$(NOW)" '+%H:%M:%S')
endif
CFLAGS += -DBUILD_DATE=\"$(DATE)\" -DBUILD_TIME=\"$(TIME)\"

CFLAGS  += -Os
QUIET   := @

# Enable to completely turn off debug output (smashfs is about 5K smaller)
#CFLAGS += -NO_DEBUG

#LDFLAGS_FTP += -g
#LDFLAGS += -g
#CFLAGS  += -g


# If verbose is specified with no other targets, then build everything
ifeq ($(MAKECMDGOALS),verbose)
verbose: all
endif
ifeq (,$(filter verbose timed, $(MAKECMDGOALS)))
QUIET   := @
else
QUIET   :=
endif

ifeq (, $(shell which $(CC) 2>/dev/null ))
$(error "No $(CC) in PATH: maybe do PATH=$$PATH:/opt/amiga13/bin")
endif

all: $(PROGROM)
	@:

dis:
	m68k-amigaos-objdump -b binary -D $(PROGROM) --adjust-vma=0x00f80000 | less

define DEPEND_SRC
# The following line creates a rule for an object file to depend on a
# given source file.
$(patsubst %,$(2)/%,$(filter-out $(2)/%,$(basename $(1)).o)) $(filter $(2)/%,$(basename $(1)).o): $(1)
endef
$(foreach SRCFILE,$(SRCS),$(eval $(call DEPEND_SRC,$(SRCFILE),$(OBJDIR))))


$(OBJS): amiga_chipset.h screen.h printf.h util.h serial.h timer.h
$(OBJDIR)/serial.o: keyboard.h
$(OBJDIR)/sprite.o: sprite.h
$(OBJDIR)/main.o: sprite.h keyboard.h reset.h
$(MED_OBJS): med_cmdline.h med_cmds.h med_main.h med_readline.h pcmds.h
$(MED_OBJS):: CFLAGS += -Wno-unused-parameter

$(OBJS): Makefile | $(OBJDIR)
	@echo Building $@
	$(QUIET)$(CC) $(CFLAGS) -c $(filter %.c,$^) -Wa,-a,-ad >$(@:.o=.lst) -o $@

$(PROG): $(OBJS) rom.ld

$(PROG):
	@echo Building $@
	$(QUIET)$(LD) $(filter %.o,$^) $(LDFLAGS) -Map=$(OBJDIR)/$@.map > $(OBJDIR)/$@.lst -o $(@:.rom=.exe) -Trom_exe.ld

#
# XXX: Using dd to create the ROM image is quite broken because it
# doesn't correctly copy the data section because there is intermediate
# data in the Amiga executable between the text and data sections which
# needs to be removed.
#
# TODO: Write program to extract text and data sections, since for an
#       unknown reason, m68k-amiga-objcopy can't recognize the Amiga
#       executable.
#
$(PROGROM): $(PROG) $(DEHUNK)
	@echo Building $@
#	$(QUIET)$(LD) $(filter %.o,$^) $(LDFLAGS) -Map=$(OBJDIR)/$@.map > $(OBJDIR)/$@.lst -o $@ -Trom.ld
	$(QUIET)$(DEHUNK) $(PROG) $@ $(VERBOSE)

$(DEHUNK): dehunk.c
	cc -o $@ $?

$(OBJDIR):
	mkdir -p $@

clean clean-all:
	@echo Cleaning
	@rm -rf $(OBJS) $(OBJDIR)
