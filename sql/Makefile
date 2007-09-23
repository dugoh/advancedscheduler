TYPES=functions \
	tables \
	triggers \
	views \
	roles

.PHONY: $(TYPES)

all: $(TYPES)

tables: roles

views: tables

triggers: tables

functions: tables views

$(TYPES):
	cd $@ && make 
