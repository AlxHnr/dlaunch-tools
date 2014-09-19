# This makefile builds all files in src/. Files not containing an unit
# declaration will be build to separate programs and linked against all
# objects with an unit declaration.
UNITS := ${patsubst src/%.scm,build/%.o,\
	${shell grep -rl '^(declare (unit' src/}}
OBJECTS  := $(patsubst src/%.scm,build/%.o,$(wildcard src/*.scm))
PROGRAMS := $(patsubst %.o,%,$(filter-out $(UNITS),$(OBJECTS)))
TEST_PROGRAMS := $(patsubst test/%.scm,build/test/%,$(wildcard test/*.scm))
INSTALL_PREFIX ?= /usr/local

# Build targets.
.SECONDARY: $(OBJECTS)
.PHONY: all
all: $(PROGRAMS)

build/%.o: src/%.scm
	mkdir -p build/ && csc -O3 -c $< -o $@

build/%: build/%.o $(UNITS)
	csc $^ -o $@

# Installation targets.
.PHONY: install uninstall
install: $(PROGRAMS)
	mkdir -p "$(INSTALL_PREFIX)/bin/"
	cp -v $^ "$(INSTALL_PREFIX)/bin/"

uninstall:
	@for program in $(PROGRAMS:build/%=%); do \
		rm -v "$(INSTALL_PREFIX)/bin/$$program"; \
		done
	rmdir --ignore-fail-on-non-empty "$(INSTALL_PREFIX)/bin/"

# Unit testing.
.PHONY: test
.SECONDARY: $(TEST_PROGRAMS:%=%.o)

test: $(TEST_PROGRAMS)
	mkdir -p test/tmp/
	@(for test in $(TEST_PROGRAMS); do \
		"$$test" || exit; \
	done)
	rm -rf test/tmp/

build/test/%.o: test/%.scm
	mkdir -p build/test/ && csc -O3 -c $< -o $@

build/test/%: build/test/%.o $(UNITS)
	csc $^ -o $@

# Other targets.
.PHONY: clean
clean:
	- rm -rf build/
	- rm -rf test/tmp/
