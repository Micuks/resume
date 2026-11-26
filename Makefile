TEX_EXTRA_PATH := /Library/TeX/texbin:$(HOME)/Library/TinyTeX/bin/universal-darwin:$(HOME)/Library/TinyTeX/bin/x86_64-darwin:$(HOME)/.TinyTeX/bin/x86_64-linux:$(HOME)/.TinyTeX/bin/aarch64-linux
PATH := $(PATH):$(TEX_EXTRA_PATH)
export PATH
export MKTEXTFM := 0

XELATEX_BIN := $(shell PATH="$(PATH)" command -v xelatex 2>/dev/null || echo xelatex)
TEX_EN = resume.tex
TEX_ZH = resume-zh.tex
XELATEX = $(XELATEX_BIN) -interaction=nonstopmode -halt-on-error -shell-escape
PREVIEW_DIR = preview
DPI = 200

.PHONY: all en zh preview clean

all: en zh

en: $(TEX_EN)
	$(XELATEX) -jobname=resume-en $(TEX_EN)

zh: $(TEX_ZH)
	$(XELATEX) -jobname=resume-zh $(TEX_ZH)

# Render compiled PDFs to per-page PNGs for remote viewing (needs poppler: brew install poppler)
preview: en zh
	@mkdir -p $(PREVIEW_DIR)
	pdftoppm -png -r $(DPI) resume-en.pdf $(PREVIEW_DIR)/resume-en
	pdftoppm -png -r $(DPI) resume-zh.pdf $(PREVIEW_DIR)/resume-zh
	@echo "Preview PNGs written to $(PREVIEW_DIR)/"

clean:
	rm -f *.log *.aux *.bbl *.blg *.synctex.gz *.out *.toc *.lof *.idx *.ilg *.ind *.cut *.xdv
	rm -rf $(PREVIEW_DIR)
