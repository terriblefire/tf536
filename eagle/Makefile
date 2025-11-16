# Makefile for Eagle CAM output (Gerber generation)
# Uses terriblefire78/eagle:v1 Docker container for CAM output

# Primary board (built by default)
BOARDPREFIX := tf536
BOARD := $(BOARDPREFIX).brd
CAMFILE := jlcpcb_4_layer_v9.cam
GITVERSION := $(shell git rev-parse --short HEAD 2>/dev/null || echo "unknown")
DATESTRING := $(shell date +"%Y_%m_%d")
GERBERS := $(BOARDPREFIX)_$(GITVERSION)_$(DATESTRING)

# Docker containers
EAGLE_DOCKER := docker run --rm --platform linux/amd64 -v $(CURDIR):/work -w /work terriblefire78/eagle:v1 eagle
EAGLE_PDF_DOCKER := docker run --rm --platform linux/amd64 -v $(CURDIR):/work -w /work terriblefire78/eagle-pdf python /app/generate_schematic_pdf.py

# Default target - only build main board
.PHONY: all
all: $(GERBERS).zip

# Generate gerbers and PDF
.PHONY: gerbers camfiles
gerbers: $(GERBERS).zip

camfiles: $(GERBERS)

.PHONY: pdf
pdf: $(BOARDPREFIX)_$(GITVERSION)_$(DATESTRING).pdf

.PHONY: bom
bom: $(BOARDPREFIX)_bom.csv

.PHONY: cpl
cpl: $(BOARDPREFIX)_cpl.csv

.PHONY: assembly
assembly: bom cpl
	@echo "Generated BOM and CPL files for assembly"

$(BOARDPREFIX)_bom.csv: $(BOARDPREFIX).sch extract_bom.py
	@echo "Generating BOM from $(BOARDPREFIX).sch..."
	python3 extract_bom.py $(BOARDPREFIX).sch $@

$(BOARDPREFIX)_cpl.csv: $(BOARDPREFIX).brd extract_cpl.py
	@echo "Generating CPL from $(BOARDPREFIX).brd..."
	python3 extract_cpl.py $(BOARDPREFIX).brd $@

# Main board gerber generation
$(GERBERS).zip: $(GERBERS)
	@echo "Creating Gerber archive..."
	zip -r $@ $(GERBERS)/* $(GERBERS)/*/* 2>/dev/null || zip -r $@ $(GERBERS)/*
	@echo "Gerber archive created: $@"

$(GERBERS): $(BOARD) $(CAMFILE)
	@echo "Generating Gerbers for $(BOARD) using $(CAMFILE)..."
	mkdir -p $(GERBERS)
	$(EAGLE_DOCKER) -X -dCAMJOB -j$(CAMFILE) -o$(GERBERS) $(BOARD)
	@echo "Gerbers generated in $(GERBERS)/"

# PDF schematic generation
$(BOARDPREFIX)_$(GITVERSION)_$(DATESTRING).pdf: $(BOARDPREFIX).sch
	@echo "Generating PDF schematic from $<..."
	$(EAGLE_PDF_DOCKER) $< $@
	@echo "PDF schematic generated: $@"

# Clean targets
.PHONY: clean
clean: clean-gerbers clean-pdf clean-bom clean-cpl
	@echo "Cleaned generated files"

.PHONY: clean-pdf
clean-pdf:
	rm -f *_*_*.pdf
	@echo "Cleaned PDF files"

.PHONY: clean-bom
clean-bom:
	rm -f *_bom.csv
	@echo "Cleaned BOM files"

.PHONY: clean-cpl
clean-cpl:
	rm -f *_cpl.csv
	@echo "Cleaned CPL files"

.PHONY: clean-gerbers
clean-gerbers:
	rm -rf *_*_*/ 2>/dev/null || rm -rf *_*_*/ 2>/dev/null || true
	rm -f *_*_*.zip
	@echo "Cleaned Gerber files and directories"

# Clean everything
.PHONY: distclean
distclean: clean
	@echo "Cleaned all generated files"

# List available board
.PHONY: list
list:
	@echo "Available board:"
	@echo "  $(BOARDPREFIX) (board: $(BOARD), schematic: $(BOARDPREFIX).sch)"

# Show help
.PHONY: help
help:
	@echo "Eagle CAM Output Makefile for TF536"
	@echo ""
	@echo "Default builds:"
	@echo "  $(BOARD) - Main TF536 board"
	@echo ""
	@echo "Targets:"
	@echo "  all           - Generate Gerbers for main TF536 board (default)"
	@echo "  gerbers       - Generate Gerber files and ZIP archive"
	@echo "  camfiles      - Generate Gerber files only (no ZIP)"
	@echo "  pdf           - Generate PDF schematic for main board"
	@echo "  bom           - Generate Bill of Materials CSV from schematic"
	@echo "  cpl           - Generate Component Placement List CSV from board"
	@echo "  assembly      - Generate both BOM and CPL for assembly"
	@echo "  clean         - Remove all generated files"
	@echo "  clean-gerbers - Remove Gerber files and directories"
	@echo "  clean-pdf     - Remove PDF files"
	@echo "  clean-bom     - Remove BOM files"
	@echo "  clean-cpl     - Remove CPL files"
	@echo "  distclean     - Remove all generated files"
	@echo "  help          - Show this help message"
	@echo ""
	@echo "Docker containers used:"
	@echo "  terriblefire78/eagle:v1      - For Gerber generation"
	@echo "  terriblefire78/eagle-pdf     - For PDF schematic generation"
	@echo ""
	@echo "Output files:"
	@echo "  Gerbers: $(GERBERS).zip"
	@echo "  PDF:     $(BOARDPREFIX)_$(GITVERSION)_$(DATESTRING).pdf"
