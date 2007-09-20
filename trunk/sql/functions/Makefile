#!/usr/bin/make

OBJ=	CalcNextRuntime.sql \
	ScheduleNextRun.sql


.PHONY: $(OBJ)

all: $(OBJ)

ScheduleNextRun.sql: CalcNextRuntime.sql 

$(OBJ):
	${ADSROOT}/bin/adsql.sh < $@
