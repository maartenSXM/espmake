include ../Makefile

YAML1   := proj.0.yaml
YAML2   := lilygo-tdisplays3-esphome.yaml
ESPMAKE := /tmp/espmake.$(shell echo $$PPID)
ESPHOME := /tmp/esphome.$(shell echo $$PPID)

test:
	@printf "Creating $(ESPMAKE) config using espmake from $(YAML1) ..."
	@cd ..; make --no-print-directory clean > /dev/null; 		\
	make --no-print-directory $(YAML1) >/dev/null 2> /dev/null;	\
	esphome config $(YAML1) >$(ESPMAKE) 2> /dev/null
	@printf "done.\n"
	@printf "Creating $(ESPHOME) config using esphome from $(YAML2) ..."
	@esphome config $(YAML2) >$(ESPHOME) 2> /dev/null
	@printf "done.\n"
	@printf "Comparing espmake and esphome configs..."
	@if diff $(ESPMAKE) $(ESPHOME); then			\
	    printf " OK\n*** test passed ***\n"; 		\
	    rm -rf $(ESPMAKE) $(ESPHOME);			\
    	else 							\
	    printf "*** Uh oh. Test failed. Check with:\n";	\
	    printf "diff $(ESPMAKE) $(ESPHOME)\n";		\
	    exit 1; 						\
    	fi
