# Tools

#LATEX=xelatex -interaction=nonstopmode -shell-escape
LATEX=pdflatex
TD=./utils/texdepend
GSCONV=./utils/gsconv.sh
PDFTRIMWHITE=pdfcrop

# Output file
PDF=rpz.pdf

# Input paths
TEX=tex
SVG=$(TEX)/graphics/svg
IMG=$(TEX)/graphics/img
DEPS=.deps
SRC=src
INC=$(TEX)/inc
EXMPL=examples

# Input files
# no .tex allowed in MAINTEX!
MAINTEX=rpz
BIBFILE=$(TEX)/rpz.bib
STYLES=$(TEX)/NSLReport.cls $(TEX)/NSLExtra.sty $(TEX)/NSLDisser.sty $(TEX)/NSLEskd.sty $(TEX)/NSLBook.sty
PARTS_TEX = $(wildcard $(TEX)/[0-9][0-9]-*.tex)

mkfile_path := $(abspath $(lastword $(MAKEFILE_LIST)))
mkfile_dir  := $(dir $(mkfile_path))

ifeq ($(firstword $(LATEX)), pdflatex)
	CODE_CONVERTION=iconv -f UTF-8 -t KOI8-R 
else
	CODE_CONVERTION=cat
endif

all: 
	@if [ ! -d $(TEX) ]; then \
	  make --no-print-directory example; \
	else \
	  make --no-print-directory $(PDF); \
	fi

.PHONY: all tarball clean

PARTS_DEPS=$(PARTS_TEX:tex/%=$(DEPS)/%-deps.mk)
-include $(PARTS_DEPS)

MAIN_DEP=$(DEPS)/$(MAINTEX).tex-deps.mk
-include $(MAIN_DEP)

$(DEPS)/%-deps.mk: $(TEX)/% Makefile
	mkdir -p $(DEPS)
	(/bin/echo -n "$(PDF): " ; $(TD) -print=fi -format=1 $< | grep -v '^#' | xargs /bin/echo) > $@

$(PDF): $(TEX)/$(MAINTEX).tex $(BIBFILE) # $(STYLES)
	cd tex && $(LATEX) $(MAINTEX)
#	cd tex && bibtex $(MAINTEX)
	cd tex && biber $(MAINTEX)
#	cd tex && makeindex $(MAINTEX).nlo -s nomencl.ist -o $(MAINTEX).nls 
	cd tex && $(LATEX) $(MAINTEX)
	cd tex && $(LATEX) $(MAINTEX)
#	cp tex/$(PDF) .
	@printf "Construction complete! Look at "
	@printf '\e[1;37m%-6s\e[m\n' "$(TEX)/$(PDF)"

$(INC)/svg/%.pdf : $(SVG)/%.svg
	@mkdir -p $(INC)/svg/
	
	@for f in $(SVG)/*; do \
		if [ -d $$f ]; then\
			mkdir -p $(INC)/svg/`basename $$f`;\
		fi;\
	done
		
# 	inkscape -A $@ $<
# Обрезаем поля в svg автоматом:
	inkscape -A $(INC)/svg/$*-tmp.pdf $<
	cd $(INC)/svg && \
		$(PDFTRIMWHITE) $*-tmp.pdf $*.pdf && \
		rm $*-tmp.pdf

$(INC)/img/%.pdf: $(IMG)/%.*
	mkdir -p $(INC)/img
	
	@for f in $(IMG)/*; do \
		if [ -d $$f ]; then\
			mkdir -p $(INC)/img/`basename $$f`;\
		fi;\
	done
	
	convert $< -quality 100 $@


$(INC)/src/%: $(SRC)/%
	mkdir -p $(INC)/src
	$(CODE_CONVERTION) $< > $@

clean:
	find $(TEX)/ -regextype posix-egrep -type f ! -regex "(.*\.(png|sty|tex|clo|cls|bib|bst|gitignore)|.*/graphics/.*|.*/Makefile)" -exec $(RM) {} \; ;
	$(RM) -r $(DEPS)
	$(RM) -r $(INC)

printpdfs: $(PDF)
	$(GSCONV) $(PDF)
	
example: example_eskd

example_eskd: example_eskd_fo

example_disser:
	@if [ ! -d $(TEX) ]; then \
	  cp -r ./$(EXMPL)/disser $(TEX); \
	  make --no-print-directory $(PDF); \
	else \
	  printf "Directory $(TEX) is exist already! If you want to compile an example, you should delete it manually and try again\n"; \
	fi
	
example_eskd_fo:
	@if [ ! -d $(TEX) ]; then \
	  cp -r ./$(EXMPL)/eskd_fo $(TEX); \
	  make --no-print-directory $(PDF); \
	else \
	  printf "Directory $(TEX) is exist already! If you want to compile an example, you should delete it manually and try again\n"; \
	fi	
	
example_book:
	@if [ ! -d $(TEX) ]; then \
	  cp -r ./$(EXMPL)/book $(TEX); \
	  make --no-print-directory $(PDF); \
	else \
	  printf "Directory $(TEX) is exist already! If you want to compile an example, you should delete it manually and try again\n"; \
	fi	

image:
	sudo docker build -t navsyslab/nslreport:v1 .
	
docker: image
	sudo docker run --rm -it -v $(mkfile_dir):/tmp/report navsyslab/nslreport:v1 make -C /tmp/report
	 

distclean: clean

PACK = $(addprefix NSLReport, Makefile tex/* src/* utils/*)

tarball: $(PDF) clean
	cd ..; rm NSLReport.tar.gz; tar -czf NSLReport.tar.gz $(PACK)
