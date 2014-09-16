# This makefile builds all files in src/. Files not containing an unit
# declaration will be build to separate programs and linked against all
# objects with an unit declaration.
UNITS := ${patsubst src/%.scm,build/%.o,\
	${shell grep -rl '^(declare (unit' src/}}
OBJECTS  := $(patsubst src/%.scm,build/%.o,$(wildcard src/*.scm))
PROGRAMS := $(patsubst %.o,%,$(filter-out $(UNITS),$(OBJECTS)))

.SECONDARY: $(OBJECTS)
.PHONY: all clean
all: $(PROGRAMS)
clean:
	- rm -rf build/

build/%.o: src/%.scm
	mkdir -p build/ && csc -O3 -c $< -o $@

build/%: build/%.o $(UNITS)
	csc $^ -o $@
