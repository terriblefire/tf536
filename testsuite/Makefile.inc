IV:=iverilog 
SUPPORT:=../rtl/
RTLFOLDER:=../../rtl

INCS:= -I../ -I$(SUPPORT)
XILINXMODS:= $(SUPPORT)/FDCPE.v $(SUPPORT)/FDCP.v $(SUPPORT)/PULLUP.v

%.tb: %.v
	$(IV) $< -I../ -I$(RTLFOLDER) $(RTLSOURCES) $(XILINXMODS) -o $(@)
	./$(@) || (exit 1)
clean:
	rm -f *.tb *.vcd
distclean:
	rm -f  *~
