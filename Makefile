# This Makefile runs dehash on $SRCS so that they can use c-preprocessor
# directives and C-style comments if needed.  It generates proj.$(PROJTAG).yaml.
#
# 'make clean' removes the generated yaml.
#
# The yaml file $(MAIN) defaults to main.yaml and can be set by
# editting it below or from the command line: make MAIN=my_main.yaml
#
# C-preprocessed yaml files are stored in directory $(PROJDIR).
# $(PROJDIR) defaults to proj.$(PROJTAG). $(PROJTAG) defaults to "0". 
# C-preprocessor ifdefs can be used to generate many different yaml
# projects from the same directory. It is possible to use multiple
# PROJTAGs to generate multiple yaml projects from the same yaml
# files.  See the example in this directory, especially ./config.h,
# which demonstrates ypp used on an esphome file.
#
# The file proj.$(PROJTAG).yaml can be inspected if esphome indicates
# any specific line numbers have syntax errors. 
# 
# A convenience c-preprocessor define _USER_$(USER) is defined so that
# personal yaml can be written inside, for example, #if _USER_maarten
# / #endif blocks, if your userid is 'maarten'.

MAIN	= main.yaml
SRCS	= $(wildcard *.yaml)
PROJTAG	= 0

# the make rules below require yaml files to have .yaml suffixes.
ifneq (x$(suffix $(MAIN)),x.yaml)
  $(error "The suffix of $(MAIN) yaml file must be .yaml")
endif

PROJDIR	= proj.$(PROJTAG)
PROJTAGS= $(subst proj.,,$(wildcard proj.*/))
_MAIN	= $(PROJDIR).yaml
CPP	= gcc -x c -undef -nostdinc $(DEFS) 
_YAMLS	= $(addprefix $(PROJDIR)/,$(filter-out $(wildcard proj.*.yaml),$(SRCS)))
DEFS    = -I$(PROJDIR) -I. -D_PROJTAG_$(PROJTAG)=1 -D_USER_$(USER)=1
DEHASH	= ./dehash/dehash

all:	 dehash $(_YAMLS) $(_MAIN)

$(_MAIN) $(_YAMLS): Makefile

$(_MAIN): $(PROJDIR)/$(MAIN)
	@echo "Generating $@"
	$(CPP) -E -P -MD -MP -MT $@ -MF $<.d $< > $@

.PRECIOUS: $(PROJDIR) dehash
$(PROJDIR):
	-mkdir -p $@

-include $(wildcard $(PROJDIR)/*.d)

realclean: 
	rm -rf .esphome dehash ./.dehash

clean:
	rm -rf $(PROJDIR) $(_MAIN)

# .PRECIOUS: $(PROJDIR) $(_YAMLS) $(_MAIN)
.PHONY: clean realclean all 

$(PROJDIR)/%.yaml: %.yaml
	$(DEHASH) --cpp --outdir $(PROJDIR) $<

dehash:
	git clone git@github.com:maartenwrs/dehash

