#!/usr/bin/make

OBJ= jobs.sql \
	runrecord.sql \
	machine.sql \
	runschedule.sql \
	UpcomingTimes.sql 

.PHONY: $(OBJ)

all: $(OBJ)

runrecord.sql: jobs.sql

jobs.sql: machine.sql

runschedule.sql: jobs.sql

$(OBJ):
	${ADSROOT}/bin/adsql.sh < $@
