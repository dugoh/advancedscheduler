TYPES=functions \
	tables \
	triggers \
	views

.PHONY: $(TYPES)

all: $(TYPES)

views: tables

triggers: tables

functions: tables views

$(TYPES):
	cd $@ && make 
