# This makefile builds all files in src/. Files not containing an unit
# declaration will be build to separate programs and linked against all
# objects with an unit declaration.
UNITS := ${patsubst src/%.scm,build/%.o,\
	${shell grep -rl '^(declare (unit' src/}}
OBJECTS  := $(patsubst src/%.scm,build/%.o,$(wildcard src/*.scm))
PROGRAMS := $(patsubst %.o,%,$(filter-out $(UNITS),$(OBJECTS)))
INSTALL_PREFIX ?= /usr/local

.SECONDARY: $(OBJECTS)
.PHONY: all clean install uninstall
all: $(PROGRAMS)

build/%.o: src/%.scm
	mkdir -p build/ && csc -O3 -c $< -o $@

build/%: build/%.o $(UNITS)
	csc $^ -o $@

clean:
	- rm -rf build/

install: $(PROGRAMS)
	mkdir -p "$(INSTALL_PREFIX)/bin/"
	cp -v $^ "$(INSTALL_PREFIX)/bin/"

uninstall:
	@for program in $(PROGRAMS:build/%=%); do \
		rm -v "$(INSTALL_PREFIX)/bin/$$program"; \
		done
	rmdir --ignore-fail-on-non-empty "$(INSTALL_PREFIX)/bin/"
