TEX = resume.tex
XELATEX = xelatex -interaction=nonstopmode -halt-on-error -shell-escape
PREVIEW_DIR = preview
DPI = 200

.PHONY: all en zh preview clean

all: en zh

en: $(TEX)
	$(XELATEX) -jobname=resume-en $(TEX)

zh: $(TEX)
	$(XELATEX) -jobname=resume-zh "\def\resumezh{1}\input{$(TEX)}"

# Render compiled PDFs to per-page PNGs for remote viewing (needs poppler: brew install poppler)
preview: en zh
	@mkdir -p $(PREVIEW_DIR)
	pdftoppm -png -r $(DPI) resume-en.pdf $(PREVIEW_DIR)/resume-en
	pdftoppm -png -r $(DPI) resume-zh.pdf $(PREVIEW_DIR)/resume-zh
	@echo "Preview PNGs written to $(PREVIEW_DIR)/"

clean:
	rm -f *.log *.aux *.bbl *.blg *.synctex.gz *.out *.toc *.lof *.idx *.ilg *.ind *.cut *.xdv
	rm -rf $(PREVIEW_DIR)
