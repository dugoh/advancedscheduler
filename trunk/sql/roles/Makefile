#!/usr/bin/make

OBJ=ADSAdmin.sql ADSViewer.sql

.PHONY: $(OBJ)

all: $(OBJ)

$(OBJ):
	${ADSROOT}/bin/adsql.sh < $@
