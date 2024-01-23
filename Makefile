# This Makefile runs dehash on $SRCS so that they can use c-preprocessor
# directives and C-style comments if needed. It generates yaml files
# of the form myProj_tag.yaml.
#
# 'make clean' removes the generated yaml.
#
# The yaml file $(MAIN) defaults to main.yaml and can be set by
# editting it below or from the command line: make MAIN=my_main.yaml
#
# C-preprocessed yaml files are stored in directory $(PROJDIR).
# $(PROJDIR) defaults to $(PREFIX)$(PROJTAG). $(PREFIX) defaults to "myProj_".
# $(PROJTAG) defaults to "0". 
#
# C-preprocessor ifdefs can be used to generate many different yaml
# projects from the same directory. It is possible to use multiple
# PROJTAGs to generate multiple yaml projects from the same yaml
# files.  See the example in this directory, especially ./config.h,
# which demonstrates ypp used on an esphome file.
#
# The file $(PREFIX)$(PROJTAG).yaml can be inspected if esphome indicates
# any specific line numbers have syntax errors. 
# 
# A convenience c-preprocessor define _USER_$(USER) is defined so that
# personal yaml can be written inside, for example, #if _USER_maarten
# / #endif blocks, if your userid is 'maarten'.

MAIN	= main.yaml
SRCS	= $(wildcard *.yaml)

# the make rules below require yaml files to have .yaml suffixes.
ifneq (x$(suffix $(MAIN)),x.yaml)
  $(error "The suffix of $(MAIN) yaml file must be .yaml")
endif
ifeq ($(shell test -e $(MAIN) || echo -n no),no)
  $(error "$(MAIN) not found (MAIN=xxx.yaml argument intended?)")
endif

ifneq (x$(suffix $(MAIN)),x.yaml)
  $(error "The suffix of $(MAIN) yaml file must be .yaml")
endif

PROJTAG	= 0
PREFIX	= myProj_
PROJDIR	= $(PREFIX)$(PROJTAG)
DEFS    = -I$(PROJDIR) -I. -D_PROJTAG_$(PROJTAG)=1 -D_USER_$(USER)=1

_MAIN	= $(PROJDIR).yaml
_YAMLS	= $(addprefix $(PROJDIR)/,$(filter-out $(wildcard $(PREFIX)*.yaml),$(SRCS)))

DEHASH	= ./dehash/dehash
CPP	= gcc -x c -E -P -undef -nostdinc $(DEFS) 

all:	dehash $(_YAMLS) $(_MAIN)
	@echo "./$(_MAIN) is up to date and ready for commands such as:"
	@echo "esphome config  $(_MAIN)"
	@echo "esphome compile $(_MAIN)"
	@echo "esphome upload  $(_MAIN)"

$(_MAIN) $(_YAMLS): dehash Makefile

$(_MAIN): $(PROJDIR)/$(MAIN) $(_YAMLS)
	@echo "Generating $@ from dehashed files in $(PROJDIR)/"
	$(CPP) -MD -MP -MT $@ -MF $<.d $< > $@

$(PROJDIR):
	-mkdir -p $@

$(PROJDIR)/%.yaml: %.yaml
	$(DEHASH) --cpp --outdir $(PROJDIR) $<

-include $(wildcard $(PROJDIR)/*.d)

clean:
	rm -rf $(PROJDIR) $(_MAIN)

realclean: 
	rm -rf .esphome dehash ./.dehash

.PHONY:    clean realclean all update
.PRECIOUS: $(PROJDIR) dehash

dehash:
	git clone git@github.com:maartenwrs/dehash

# update dehash and this Makefile from github
update:
	-@if [ -d "./example/dehash" ]; then 			\
		echo "Updating git repo ./example/dehash";	\
		cd example/dehash; git pull;			\
	fi
	-@if [ -d "./dehash" ]; then 				\
		echo "Updating git repo ./dehash";		\
		cd ./dehash; git pull; 				\
	fi
	-@curl https://raw.githubusercontent.com/maartenwrs/espmake/main/Makefile >Makefile.new 2> /dev/null
	-@echo "Latest espmake Makefile downloaded as Makefile.new"
	-@echo "Changes from ./Makefile to latest espmake Makefile are:"
	-diff Makefile Makefile.new

