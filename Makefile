# Copyright © 2012-2016 Marzo Sette Torres Junior
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
# Addendum: the GNU General Public License applies only to the makefile
# itself; it does not apply to code compiled with this makefile.

# Source directory list
SRCDIRS := .

# Compilers
CC := gcc
CXX := g++
COMPIL := CC CXX

# Compression
ZIP := zip

# Defines for gathering per-compiler source files from filesystem
define GatherCompilerSources
SRCS$(1)  := $(foreach EXT,$(EXTS$(1)),$(foreach SRCDIR,$(SRCDIRS),$(wildcard $(SRCDIR)/*.$(EXT))))
endef
# Defines for gathering source files from variables into a master variable
define GatherSources
$(SRCS$(1))
endef
# Source files; variables must be of the form EXTS$(COMPILER)
EXTSCC  := c
EXTSCXX := cc C cpp
EXTSHDR := h hh H hpp
EXTSASM := asm
# Gather source files into variables of the form SRCS$(COMPILER)
$(foreach COMPILER,$(COMPIL),$(eval $(call GatherCompilerSources,$(COMPILER))))
SOURCES := $(foreach COMPILER,$(COMPIL),$(call GatherSources,$(COMPILER)))
SRCSH   := $(foreach EXT,$(EXTSHDR),$(foreach SRCDIR,$(SRCDIRS),$(wildcard $(SRCDIR)/*.$(EXT))))
SRCSASM := $(foreach EXT,$(EXTSASM),$(foreach SRCDIR,$(SRCDIRS),$(wildcard $(SRCDIR)/*.$(EXT))))

# Include dirs
INCDIRS := $(foreach SRCDIR,$(SRCDIRS),-I$(SRCDIR))

# Object files
define GatherObjects
$(foreach EXT,$(EXTS$(1)),$(patsubst %.$(EXT),%.o,$(filter %.$(EXT),$(SRCS$(1)))))
endef
OBJECTS := $(subst ./,,$(foreach COMPILER,$(COMPIL),$(call GatherObjects,$(COMPILER))))

# Dependency files (one per object file)
DEPEND  := $(foreach OBJ,$(OBJECTS),$(OBJ:%.o=%.d))

# Make targets
all: bcd-gen bcd-verifier.bin

zip:
	rm -f bcd-verifier.zip
	zip -9 bcd-verifier.zip Makefile $(SRCSASM) $(SOURCES) $(SRCSH) data/TerminalFont.bin data/TerminalPal.bin LICENSE README.md

count:
	wc $(SOURCES) $(SRCSH)

clean:
	# Final binaries
	rm -f bcd-gen bcd-verifier.bin data/bcd-table.bin
	# Intermediate objects
	rm -f bcd-verifier.h bcd-verifier.lst bcd-verifier.p bcd-gen.d *~

distclean: clean
	rm -f *.zip

.PHONY: all count clean distclean zip

# Construction rules
.SUFFIXES:

data/bcd-table.bin: bcd-gen
	./bcd-gen

bcd-verifier.bin: data/bcd-table.bin $(SRCSASM)
	asl -xx -c -L -r 2 -A -U bcd-verifier.asm
	p2bin -r 0-\$$ bcd-verifier.p

bcd-gen: $(SOURCES)
	g++ -O3 -s -Wall -Wextra -pedantic -Werror -MMD -MP -o $@ $(SOURCES)

# Dependencies
-include $(DEPEND)

