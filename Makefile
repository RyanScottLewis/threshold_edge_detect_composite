RM         ?= rm -f
MV         ?= mv
MKDIR      ?= mkdir
PROCESSING ?= processing-java

ROOTDIR    ?= $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))
SRCDIR     ?= src
BUILDDIR   ?= build

NAME       ?= $(notdir $(ROOTDIR))

SKETCH_PDE ?= $(SRCDIR)/*.pde
SKETCH_TMP ?= $(BUILDDIR)/src
SKETCH_EXE ?= $(BUILDDIR)/$(NAME)

.PHONY: build run clean

build: $(SKETCH_EXE)

run: $(SKETCH_EXE)
	$(SKETCH_EXE)

clean:
	$(RM) -r $(BUILDDIR)

$(SKETCH_EXE): $(SKETCH_PDE) | $(BUILDDIR)/
	$(PROCESSING) --sketch="$(SRCDIR)" --force --output="$(BUILDDIR)" --export
	$(MV) $(SKETCH_TMP) $(SKETCH_EXE)

$(BUILDDIR)/:
	$(MKDIR) -p $@

