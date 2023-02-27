.PHONY: builddoc

builddoc:
	cp ./etc/nighthawk.txt.template ./doc/nighthawk.txt

all: builddoc
