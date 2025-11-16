BOARDS:=$(shell cat ./boards.txt)
GITVERSION:=`git rev-parse --short HEAD`
DATESTRING:=`date +"%Y_%m_%d"`
GITREPO:=$(shell basename `git rev-parse --show-toplevel`)
RELEASE_PACKAGE=$(GITREPO)_$(DATESTRING)_$(GITVERSION).zip

.PHONY: $(BOARDS)
all: clean
	@- $(foreach BOARD,$(BOARDS), make -C $(BOARD);)
zip: clean
	@- $(foreach BOARD,$(BOARDS), make -C $(BOARD) zip; zip $(RELEASE_PACKAGE) $(BOARD)/*.zip; )
clean: 
	$(RM) $(RELEASE_PACKAGE)
	@- $(foreach BOARD,$(BOARDS), make -C $(BOARD) clean;)
	$(RM) *.zip
distclean: 
	@- $(foreach BOARD,$(BOARDS), make -C $(BOARD) distclean;)
