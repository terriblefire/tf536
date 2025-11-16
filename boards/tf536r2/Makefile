REVISION=2
BOARD:=tf536
CLOCK_PHASE?=7

all: $(BOARDPREFIX)
include ../Makefile.inc

$(BOARDPREFIX): a500 cdtv

# Build XC95288XL variant by default (recommended)
a500: a500-288

a500-288:
	$(XILINXENV) make -f ../Makefile.cpld BOARD=$(BOARD) SOURCES=$(SOURCES) SUBPROJ=main REVISION=$(REVISION) OPTMODE=speed OPTIMISE=speed CLOCK_PHASE=$(CLOCK_PHASE) CHIPSIZE=288 TARGET=A500

# XC95144XL variant (manual build only - may not fit)
a500-144:
	$(XILINXENV) make -f ../Makefile.cpld BOARD=$(BOARD) SOURCES=$(SOURCES) SUBPROJ=main REVISION=$(REVISION) OPTMODE=speed OPTIMISE=speed CLOCK_PHASE=$(CLOCK_PHASE) CHIPSIZE=144 TARGET=A500

# Build XC95288XL variant by default (recommended)
cdtv: cdtv-288

cdtv-288:
	$(XILINXENV) make -f ../Makefile.cpld BOARD=$(BOARD) SOURCES=$(SOURCES) SUBPROJ=main REVISION=$(REVISION) OPTMODE=speed OPTIMISE=speed CLOCK_PHASE=$(CLOCK_PHASE) CHIPSIZE=288 TARGET=CDTV

# XC95144XL variant (manual build only - may not fit)
cdtv-144:
	$(XILINXENV) make -f ../Makefile.cpld BOARD=$(BOARD) SOURCES=$(SOURCES) SUBPROJ=main REVISION=$(REVISION) OPTMODE=speed OPTIMISE=speed CLOCK_PHASE=$(CLOCK_PHASE) CHIPSIZE=144 TARGET=CDTV
