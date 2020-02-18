TEX = $(wildcard *.tex)
PDFTEX = $(wildcard *.pdftex)
PSTEX = $(wildcard *.pstex)
PSTEX_T = $(wildcard *.pstex_t)
EPS = $(wildcard *.eps)
DVI = $(patsubst %.tex,%.dvi, $(TEX))
PS  = $(patsubst %.dvi,%.ps, $(DVI))
PDF = $(patsubst %.ps,%.pdf, $(PS))

%.dvi: %.tex $(EPS) $(PSTEX) $(PSTEX_T)
	( \
	\latex $<; \
	while \grep -q "Rerun to get cross-references right." $(<:.tex=.log); \
	do \
		\latex $<; \
	done \
	)

%.ps: %.dvi ; dvips $< -o $@

%.pdf: %.dvi ; dvi2pdf_Perso $<

all: $(DVI) $(PS) $(PDF)

allpdf: $(DVI) $(PS) $(PDF)

clean:
	rm -f $(PS) $(DVI) $(PDF) *.log *.aux
