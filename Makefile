DIAGEN ?= ~/bin/diagen

RSTEXT := $(shell find . -name '*.rst')
DIAGRAMS := $(shell find . -name '*.gv.m4')

.PHONY: html svg

html: svg $(RSTEXT:.rst=.html)

svg: $(DIAGRAMS:.gv.m4=.svg)

%.html: %.rst
	pandoc -s -o $@ $<

%.svg: %.gv.m4
	$(DIAGEN) $< $@
