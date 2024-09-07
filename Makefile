# This Makefile is from https://github.com/maartenSXM/espmake

# It is esphome project independent since all esphome project
# configuration can be conditionally included from yaml that the
# generated final esphome.yaml can adapt at build time. There are
# a some C preprocessor defines that your esphome yaml can use to do
# such # adaptation. See CPT_EXTRA_DEFS below.

# Refer to https://github.com/maartenSXM/espmake/blob/main/README.md
# for more details.

ifeq (,$(MAKECMDGOALS))
MAKECMDGOALS := all
endif
MAKE            := $(MAKE) --no-print-directory
MAKEFILE        := $(lastword $(MAKEFILE_LIST))

ifeq (,$(ESPMAKE_HOME))
  $(info Makefile: please define ESPMAKE_HOME to use this Makefile.)
  $(error Makefile: Refer to $(ESPMAKE_HOME)/Bashrc for details.)
endif

# Get cpptext.

ifeq (,$(wildcard $(ESPMAKE_HOME)/cpptext/.git))
  ifneq (,$(BAIL))
    $(error $(MAKEFILE): make loop detected. Bailing out.)
  endif

$(MAKECMDGOALS): 
	@printf "$(MAKEFILE): cloning cpptext\n"
	cd $(ESPMAKE_HOME) && \
	    git clone git@github.com:maartenSXM/cpptext
	cd $(ESPMAKE_HOME) && cpptext && git checkout main
	@printf "$(MAKEFILE): Restarting \"make $(MAKECMDGOALS)\"\n"
	$(MAKE) BAIL=1 $(MAKECMDGOALS)
else

# The rest of this Makefile is inside the 'ifeq' cpptext check from above.

ESPMAKE_INIT ?= ./espinit.yaml
ifeq (,$(wildcard $(ESPMAKE_INIT))) # check specified initial file exists
    $(info $(MAKEFILE): $(ESPMAKE_INIT) not found.)
    $(error $(MAKEFILE): Perhaps run this in the example directory?)
endif

# set the variable that cpptext/Makefile.cpptext uses
ESP_INIT = $(ESPMAKE_INIT)

# Check if PRJ= was specified on the command line to select a project.
ifneq (,$(PRJ))
  ifeq (,$(wildcard $(PRJ)))	    # check specified espmake project exists
    $(error $(MAKEFILE): $(PRJ) not found)
  endif
  $(shell echo $(PRJ) $(ESPMAKE_HOME)/.espmake_project)
else
  ifneq (,$(wildcard $(ESPMAKE_HOME)/.espmake_project))
    PRJ := $(shell cat $(ESPMAKE_HOME)/.espmake_project)
  else
    ifeq (,$(wildcard $(ESP_INIT)))
      $(error $(MAKEFILE): ESP_INIT not found)
    endif
    PRJ = $(ESP_INIT)
  endif
endif

ESPMAKE_PRJ_PATH = $(PRJ)
ESPMAKE_PRJ_DIR  = $(patsubst %/,%,$(dir $(PRJ)))
ESPMAKE_PROJECT  = $(basename $(notdir $(ESPMAKE_PRJ_PATH)))

# CPT_BUILD_DIR is where espmake projects are built.  It can be changed here.
# the depth of CPT_BUILD_DIR changes. Refer to the ESPMAKE_HOME comments below
# for more details.

CPT_BUILD_DIR = $(ESPMAKE_HOME)/build/$(ESPMAKE_PROJECT)
ESPMAKE_BUILD_LOG = $(CPT_BUILD_DIR)/makeall.log

# restart 'make all' with logging to $(CPT_BUILD_DIR)/build.log and console
ifeq (all,$(ESPMAKE_AUTOLOG)$(MAKECMDGOALS))
  SHELL:=bash
all:
	@$(MAKE) -k ESPMAKE_AUTOLOG=1 $(MAKECMDGOALS) |& \
		tee $(ESPMAKE_BUILD_LOG)
	@printf "Makefile: \"make all\" log is $(ESPMAKE_BUILD_LOG)\n"
else

# CPT_GEN is the set of files that cpptext runs the C preprocessor on.
# They can include files from CPT_SRCS (defined below) since the cpptext
# tool arranges that de-commented copies are included, not the originals.

# CPT_GEN  ?= partitions.csv lily.yaml
CPT_GEN  ?= $(ESP_INIT)

# Use this to list subdirectories to #include yaml files from.
ESPMAKE_DIRS ?= 

# CPT_SRCS is the set of files that cpptext will remove hash-style
# comments from while leaving any C preprocessor directives so that
# the file can subsequently be used as a #include by one of the
# CPT_GEN files.

# Builds the list of CPT_SRCS by looking for .yaml files in $(ESPMAKE_DIRS).

CPT_SRCS += $(sort $(filter-out ./secrets.h,$(foreach d,$(ESPMAKE_DIRS),$(wildcard $(d)/*.yaml))) $(CPT_GEN))

# In addition to updates to $(CPT_SRCS) triggering a rebuild of esphome.yaml,
# updates to source files in $(ESP_DEPS) are also triggers.

ESPMAKE_DEPS ?= 

ESP_DEPS += $(foreach d,$(ESPMAKE_DEPS),$(wildcard $(d)/*.c) \
		$(wildcard $(d)/*.cpp) $(wildcard $(d)/*.h))

# If there is a secrets.h file in ./ or ../, use it

ifneq (,$(wildcard ./secrets.h))
  CPT_EXTRA_FLAGS += -include ./secrets.h
else
  ifneq (,$(wildcard ../secrets.h))
    CPT_EXTRA_FLAGS += -include ../secrets.h
  endif
endif

# Use this to list additional #include directories

CPT_EXTRA_INCS +=

# These #defines are for project adapation. 

CPT_EXTRA_DEFS += -D ESPMAKE_HOME=../..				\
		  -D ESPMAKE_BUILD_PATH=$(CPT_BUILD_DIR)	\
		  -D ESPMAKE_PRJ_DIR=$(ESPMAKE_PRJ_DIR)		\
		  -D ESPMAKE_PROJECT_NAME=$(ESPMAKE_PROJECT)	\
		  -D ESPMAKE_PROJECT_$(ESPMAKE_PROJECT)		\
		  -D ESPMAKE_USER_NAME=$(USER)			\
		  -D ESPMAKE_USER_$(USER)

# The reason ESPMAKE_HOME is set above to two levels up i.e. ../.. is because
# the generated esphome.yaml ends up in $(CPT_BUILD_DIR) which is
# build/$(ESPMAKE_PROJECT) which is two levels down from this directory.
# ESPMAKE_HOME is used in yaml or C/C++ files to refer to files and directories
# under this directory and is define as a relative so that build trees
# are reproducable regardless of where they are built.

# This includes the cpptext Makefile fragment that will dehash yamls files.
# In turn, it will include cpptext/Makefile.esphome which handles the esphome
# file generation and platformio build steps.

include $(ESPMAKE_HOME)/cpptext/Makefile.cpptext

print-config:: $(ESP_INIT)
	@printf "Makefile variables:\n"
	@printf "  ESPMAKE_PROJECT: $(ESPMAKE_PROJECT)\n"
	@printf "  ESP_INIT: $(ESP_INIT)\n"
	@printf "  CPT_GEN:  $(CPT_GEN)\n"
	@printf "  CPT_SRCS:\n"
	@$(foreach f,$(CPT_SRCS),printf "    $(f)\n";)
	@printf "  ESP_DEPS:\n"
	@$(foreach f,$(ESP_DEPS),printf "    $(f)\n";)
	@printf "Makefile #defines available to yaml files:"
	@printf "  $(subst -, ,$(subst -D,#define,$(CPT_EXTRA_DEFS)))\n" | sed -e 's/ #/\n  #/g' -e 's/=/ /g'
	@printf "For #defaults available to yaml files, "
	@printf "use: make print-defaults\n"

.PHONY: print-config

# this endif is from the autolog restart
endif

# This last endif is needed from the git submodule install check above

endif

