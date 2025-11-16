.PHONY: version.inc
SHELL:=/bin/bash
BOARD:=tf536
REVISION:=2
GITVERSION:=`git rev-parse --short HEAD`
DATESTRING:=`date +"%Y-%m-%d"`

# Detect platform and setup Docker if needed
UNAME := $(shell uname)
DOCKERIMAGE := terriblefire78/vbcc:latest

ifneq ($(UNAME), Linux)
	VASMENV = docker run --rm --platform linux/amd64 -v $(CURDIR)/..:/work -w /work/rom $(DOCKERIMAGE)
	AS = vasmm68k_mot
else
	# On Linux, try local vasm first, fall back to Docker if not available
	VASM_LOCAL := $(shell which vasmm68k_mot 2>/dev/null)
	ifdef VASM_LOCAL
		VASMENV =
		AS = vasmm68k_mot
	else
		VASMENV = docker run --rm --platform linux/amd64 -v $(CURDIR)/..:/work -w /work/rom $(DOCKERIMAGE)
		AS = vasmm68k_mot
	endif
endif

all: bootrom.v
version.inc:
	echo -ne "${BOARD}r$(REVISION)_$(DATESTRING)_$(GITVERSION)" > $@
bootrom.rom: version.inc
	$(VASMENV) $(AS) -cnop=0x0000 -Fbin -m68060 bootrom.asm -o $@
bootrom.v: bootrom.rom
	./bin2vrlg -f bootrom.rom > ../rtl/$@
clean:
	rm -rf *~ *.rom *.v
distclean: clean
	rm -rf \#*
