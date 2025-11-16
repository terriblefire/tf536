BOARDPREFIX=$(BOARD)r$(REVISION)
GITVERSION:=`git rev-parse --short HEAD`
DATESTRING:=`date +"%Y_%m_%d"`

RTLFOLDER=../../rtl/
ROMFOLDER=../../rom/

TOOLSFOLDER=../../utils/
DRIVERSFOLDER=../../drivers/
SOURCES="./$(BOARD)r$(REVISION)_main_top.v $(RTLFOLDER)/main_top.v $(RTLFOLDER)/m6800.v $(RTLFOLDER)/intreqr.v $(RTLFOLDER)/interrupt.v $(RTLFOLDER)/ata.v $(RTLFOLDER)/clocks.v $(RTLFOLDER)/autoconfig.v $(RTLFOLDER)/gayle.v $(RTLFOLDER)/sdram.v $(RTLFOLDER)/sdram_init.v $(RTLFOLDER)/bootrom.v $(RTLFOLDER)/bus.v" 

ifndef SERIALNO
    SERIALNO=1000
    SUFFIX=_alpha
endif

ifndef SUFFIX
    SUFFIX=_$(SERIALNO)
endif

UNAME := $(shell uname)
XILINXENV:=
SRCROOT:=$(abspath $(PWD)/../../)
BRDROOT:=$(subst $(SRCROOT),,$(abspath $(PWD)))
DOCKERIMAGE:=terriblefire78/xilinx:v1

ifneq ($(UNAME), Linux)
      XILINXENV=docker run --rm --platform linux/amd64 -v $(SRCROOT):/host -w /host/$(BRDROOT) $(DOCKERIMAGE)
endif

.PHONY: $(ROMFOLDER)/bootrom.v

$(ROMFOLDER)/bootrom.v:
	make -C $(ROMFOLDER) BOARD=$(BOARD) REVISION=$(REVISION)

zip: distclean $(BOARDPREFIX)
	zip $(BOARDPREFIX)_$(DATESTRING)_$(GITVERSION)$(SUFFIX).zip *.jed README.txt 
clean:	
	rm -rf work _xmsgs *.zip xlnx_auto_* *.jed *.svf
distclean: clean
	rm -f *.jed *~ *.svf 
   
