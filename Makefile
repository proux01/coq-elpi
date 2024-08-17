dune = dune $(1) $(DUNE_$(1)_FLAGS)

elpi/dune: elpi/dune.in
	@rm -f $@
	@echo "; generated by configure.sh from configure.in, do not edit" > $@
	@if $$(coqc --version | grep -q "8.19\|8.20") ; then \
	  sed -e 's/@@STDLIB_THEORY@@//' $< >> $@ ; \
	else \
	  sed -e 's/@@STDLIB_THEORY@@/(theories Stdlib)/' $< >> $@ ; \
	fi
	@chmod a-w $@

all: elpi/dune
	$(call dune,build)
.PHONY: all

build-core: elpi/dune
	$(call dune,build) theories
.PHONY: build-core

build-apps: elpi/dune
	$(call dune,build) $$(find apps -type d -name theories)
.PHONY: build-apps

build: elpi/dune
	$(call dune,build) -p coq-elpi @install
.PHONY: build

test-core: elpi/dune
	$(call dune,runtest) tests
.PHONY: test-core

test-apps: elpi/dune
	$(call dune,build) $$(find apps -type d -name tests)
.PHONY: test-apps

test: elpi/dune
	$(call dune,runtest)
	$(call dune,build) $$(find apps -type d -name tests)
.PHONY: test

examples: elpi/dune
	$(call dune,build) examples
.PHONY: examples

doc: build
	@echo "########################## generating doc ##########################"
	@mkdir -p doc
	@$(foreach tut,$(wildcard examples/tutorial*$(ONLY)*.v),\
		echo ALECTRYON $(tut) && OCAMLPATH=$(shell pwd)/_build/install/default/lib ./etc/alectryon_elpi.py \
		    --frontend coq+rst \
			--output-directory doc \
		    --pygments-style vs \
			-R $(shell pwd)/_build/install/default/lib/coq/user-contrib/elpi_elpi elpi_elpi \
			-R $(shell pwd)/_build/install/default/lib/coq/user-contrib/elpi elpi \
			$(tut) &&) true
	@cp _build/default/examples/stlc.html doc/
	@cp etc/tracer.png doc/

clean:
	$(call dune,clean)
.PHONY: clean

install: elpi/dune
	$(call dune,install) coq-elpi
.PHONY: install

nix:
	nix-shell --arg do-nothing true --run "updateNixToolBox && genNixActions"
.PHONY: nix
