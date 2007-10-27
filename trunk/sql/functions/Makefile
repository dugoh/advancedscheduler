#!/usr/bin/make

OBJ=	CalcNextRuntime.sql \
	ScheduleNextRun.sql \
	StringToRecs.sql


.PHONY: $(OBJ)

all: $(OBJ)

ScheduleNextRun.sql: CalcNextRuntime.sql 

CalcNextRuntime.sql: StringToRecs.sql

$(OBJ):
	${ADSROOT}/bin/adsql.sh < $@
