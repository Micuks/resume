TEX = resume.tex
XELATEX = xelatex -interaction=nonstopmode -halt-on-error -shell-escape

.PHONY: all en zh clean

all: en zh

en: $(TEX)
	$(XELATEX) -jobname=resume-en $(TEX)

zh: $(TEX)
	$(XELATEX) -jobname=resume-zh "\def\resumezh{1}\input{$(TEX)}"

clean:
	rm -f *.log *.aux *.bbl *.blg *.synctex.gz *.out *.toc *.lof *.idx *.ilg *.ind *.cut *.xdv
