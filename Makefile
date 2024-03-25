# Modified from https://github.com/sjtug/SJTUThesis/blob/cf78cdb9992c0a679a61f87b001aa79041a10a20/Makefile
# Makefile for SJTUThesis

# Basename of thesis
THESIS = main

# Option for latexmk

# Check: Typesetting Engines
ENGINES = -xelatex -lualatex
ifneq ($(filter all pvc, $(MAKECMDGOALS)), )
ifeq ($(filter $(ENGINES), $(ENGINE)), )
  $(info Expected $$ENGINE in {$(ENGINES)}, Got "$(ENGINE)")
  $(info Set default $$ENGINE to "-xelatex")
  ENGINE = -xelatex
endif
endif

LATEXMK_OPT = -quiet -file-line-error -halt-on-error -interaction=nonstopmode -shell-escape $(ENGINE) main
LATEXMK_OPT_PVC = $(LATEXMK_OPT) -pvc

# make deletion work on Windows
ifdef SystemRoot
	RM = del /Q
	OPEN = start
else
	RM = rm -f
	OPEN = open
endif

.PHONY : all pvc view wordcount clean cleanall FORCE_MAKE

all : $(THESIS).pdf

$(THESIS).pdf : $(THESIS).tex FORCE_MAKE
	@latexmk $(LATEXMK_OPT) $<

pvc : $(THESIS).tex
	@latexmk $(LATEXMK_OPT_PVC) $(THESIS)

view : $(THESIS).pdf
	$(OPEN) $<

wordcount : $(THESIS).tex
	@if grep -v ^% $< | grep -q '\\documentclass\[[^\[]*english'; then \
		texcount $< -inc -char-only | awk '/total/ {getline; print "英文字符数\t\t\t:",$$4}'; \
	else \
		texcount $< -inc -ch-only   | awk '/total/ {getline; print "纯中文字数\t\t\t:",$$4}'; \
	fi
	@texcount $< -inc -chinese | awk '/total/ {getline; print "总字数（英文单词 + 中文字）\t:",$$4}'

clean :
	-@latexmk -c -bibtex -silent $(THESIS).tex styledef.tex 2> /dev/null

cleanall :
	-@latexmk -C -bibtex -silent $(THESIS).tex styledef.tex 2> /dev/null