
SOURCES:= $(shell find $(SOURCEDIR) -name 'test_*.v')
TESTOBJS=$(subst .v,.tb,$(SOURCES))
TARGETS=$(subst .v,,$(SOURCES))

RTLFOLDER:=../../rtl
RTLSOURCES=$(RTLFOLDER)/interrupt.v

.PHONY: $(TARGETS)
all: clean $(TESTOBJS)
include ../Makefile.inc