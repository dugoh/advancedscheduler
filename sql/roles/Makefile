#!/usr/bin/make

OBJ=ADSAdmin.sql ADSViewer.sql ADSOperator.sql

.PHONY: $(OBJ)

all: $(OBJ)

ADSOperator.sql: ADSViewer.sql

ADSAdmin.sql: ADSOperator.sql

$(OBJ):
	${ADSROOT}/bin/adsql.sh < $@
