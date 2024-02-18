# espmake

espmake assists with managing multiple esphome project variants that share
yaml source files.  espmake also enables the sharing of pin definitions
and configuration definitions between yaml and C / C++ files. See
main.yaml, config.h and pins.h for examples of that.

espmake generates a new esphome home yaml file from an existing esphome
project.  The reason a new esphome yaml is generated is because espmake
runs the existing esphome project's yaml files through the
C-preprocessor (cpp)

Once a yaml file is generated by the Makefile,  esphome commands
can be issued upon it, such as:
```bash
 esphome compile myProj_0.yaml
 esphome upload  myProj_0.yaml
 esphome logs    myProj_0.yaml
```

See 'esphome -h' for more details on esphome commands.

## Installation

espmake is basically a Makefile in this directory which s manually copied
into an existing esphome project directory and to enable the make command.
Note that this manual installation procedure assumes that the destination
project doesn't have a Makefile already. If it does, this Makefile could
be renamed and included from the project Makefile.  However that is left
as an exercise for the reader.

## Makefile User variables

These Makefile variables can be changed from their defaults by either
editting the Makefile or overriding them with an argument to make such as
```bash
make MAIN=init.yaml
```

### MAIN

The initial/main yaml file that includes the others. it defaults
to "main.yaml".

### PREFIX

espmake generates a single esphome yaml filename named $(PREFIX)$(PROJTAG).
PREFIX defaults to "./myProj_"

### PROJTAG

espmake generates a single esphome yaml filename named $(PREFIX)$(PROJTAG).
PROJTAG defaults to "0" but can be any character string of any length.
To build different project variants from the same esphome project
directory, specify a different PROJTAG for each.

Argument -D_PROJTAG_$(PROJTAG) is passed to the cpp by espmake so that
esphome yaml sources can vary using #if  directives such as:
```code
#if _PROJTAG_foo
# yaml code only for project foo goes here
#endif
```

## Generated files
espmake generates esphome project file <PREFIX><PROJTAG>.yaml
Intermediate C-preprocessed files used to generate <PREFIX><PROJTAG>.yaml
are stored in directory <PREFIX><PROJTAG>/

Both can be deleted using 'make clean'.

## Other

There are some additional comments describing Makefile features in the
Makefile.

There are some aliases in file Bashrc which may be helpful for issuing
esphome commands.

espmake uses a small github project called dehash
(https://github.com/maartenwrs/dehash) to remove hash-style comments
before running files through the c-preprocessor.

# Credits

Thank you to Landon Rohatensky for the exemplary esphome yaml file
https://github.com/landonr/lilygo-tdisplays3-esphome used to demonstrate
espmake configuration, build and also as used in the test subdirectory.

# Disclaimers

Tthe author has not attempted to use espmake with Visual Studio.

# MacOS Note
Note: on MacOS, you need GNU sed to run dehash.sh, which espmake invokes . To install GNU sed, please do this:
```
brew install gsed
```
and then add this line to your .bashrc:
```
export PATH="/opt/homebrew/opt/gnu-sed/libexec/gnubin:$PATH"
```
and then 'source .bashrc' or logout and log back in.

