# This Makefile is from https://github.com/maartenwrs/espmake
# It is esphome project independent since all esphome project config
# can be conditionally included from yaml, when this Makefile is used
# to build an esphome project. Instead of editting this Makefile, 
# consider adding a main.yaml to your project that #includes yaml
# files for your project as needed.  That will future-proof your Makefile
# if you ever need to update it using "make update" from the espmake repo.
# 
# A convenience c-preprocessor define _PROJTAG_$(PROJTAG) is #define-ed as
# true so that project-specific yaml can be written inside, for example,
# #if _PROJTAG_foo ... #endif blocks, when PROJTAG is set to "foo".
# Also, _PROJTAG is #define-ed to be the project tag - e.g. "foo".
# 
# A convenience c-preprocessor define _USER_$(USER) is #define-ed as true
# so that personal yaml can be written inside, for example,
# #if _USER_maarten ... #endif blocks, if your userid is "maarten".
# Also, _USER is #define-ed to be the userid - e.g. "maarten".
#
# Refer to https://github.com/maartenwrs/espmake/blob/main/README.md
# for more details.

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

OUTDIR	= .
PROJTAG	= 0
PREFIX	= myProj_
PROJDIR	= $(OUTDIR)/$(PREFIX)$(PROJTAG)
CPPINCS = -I$(PROJDIR) -I.
CPPDEFS = -D_PROJTAG_$(PROJTAG)=1 -D_PROJTAG=$(PROJTAG) -D_USER_$(USER)=1 -D_USER=$(USER)

_MAIN	= $(PROJDIR).yaml
_YAMLS	= $(addprefix $(PROJDIR)/,$(filter-out $(wildcard $(PREFIX)*.yaml),$(SRCS)))

DEHASH	= $(OUTDIR)/dehash/dehash.sh --cpp
CPP	= gcc -x c -E -P -undef -nostdinc $(CPPINCS) $(CPPDEFS) 

all:	$(OUTDIR)/dehash $(PROJDIR) $(_YAMLS) $(_MAIN)
ifneq (,$(findstring esphome,$(VIRTUAL_ENV))) # check if esphome venv
	-@if [ "$(OUTDIR)" != "." -a -f "secrets.yaml" ]; then 		   \
	    if [ -L "$(OUTDIR)/secrets.yaml" ]; then 			   \
	    	rm -f $(OUTDIR)/secrets.yaml;				   \
		echo "re-linking $(OUTDIR)/secrets.yaml";		   \
	    else							   \
		echo "linking $(OUTDIR)/secrets.yaml";			   \
	    fi;								   \
	    ln -s $(PREFIX)$(PROJTAG)/secrets.yaml $(OUTDIR)/secrets.yaml; \
	fi
	@echo "$(_MAIN) is up to date"
	esphome compile $(_MAIN)
else
	@echo "$(_MAIN) is up to date"
endif


$(_MAIN) $(_YAMLS): $(OUTDIR)/dehash Makefile

$(_MAIN): $(PROJDIR)/$(MAIN) $(_YAMLS)
	@echo "Generating $@ from dehashed files in $(PROJDIR)/"
	$(CPP) -MD -MP -MT $@ -MF $<.d $< > $@

$(OUTDIR):
	-mkdir -p $@

$(PROJDIR):
	-mkdir -p $@

$(PROJDIR)/%.yaml: %.yaml
	$(DEHASH) $< > $@

-include $(wildcard $(PROJDIR)/*.d)

clean:
	rm -rf $(PROJDIR) $(_MAIN)
ifneq (,$(findstring esphome,$(VIRTUAL_ENV))) # check if esphome venv
	@if [ "$(OUTDIR)" != "." -a -f "secrets.yaml" ]; then 	\
	    if [ -L "$(OUTDIR)/secrets.yaml" ]; then 		\
	    	echo "rm $(OUTDIR)/secrets.yaml";		\
	    	rm -f $(OUTDIR)/secrets.yaml;			\
	    fi;							\
	fi
endif

realclean: clean
	rm -rf $(OUTDIR)/dehash .esphome

.PHONY:    clean realclean update
.PRECIOUS: $(PROJDIR) $(OUTDIR) $(OUTDIR)/dehash

$(OUTDIR)/dehash:
	-@mkdir -p $(OUTDIR)
	cd $(OUTDIR); git clone https://github.com/maartenwrs/dehash

# pull dehash repo and this Makefile from github
update:
	-@if [ -d "$(OUTDIR)/dehash" ]; then 			\
		echo "Updating git repo $(OUTDIR)/dehash";	\
		cd $(OUTDIR)/dehash; git pull; 			\
	fi
	-@curl https://raw.githubusercontent.com/maartenwrs/espmake/main/Makefile >Makefile.new 2> /dev/null
	-@echo "Latest espmake Makefile downloaded as Makefile.new"
	-@echo "Changes from ./Makefile to latest espmake Makefile are:"
	-diff Makefile Makefile.new

