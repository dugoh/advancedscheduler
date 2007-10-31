#!/usr/bin/make

ROLES=ADSAdmin.sql ADSViewer.sql ADSOperator.sql
TRIGGERS=SetUpNextRun.sql
TABLES= jobs.sql \
	runrecord.sql \
	machine.sql \
	runschedule.sql \
	UpcomingTimes.sql 
FUNCTIONS=	CalcNextRuntime.sql \
		ScheduleNextRun.sql \
		StringToRecs.sql \
		sequence.sql
VIEWS=PendingJobs.sql

OBJ=$(ROLES) $(TRIGGERS) $(TABLES) $(FUNCTIONS) $(VIEWS)

.PHONY: $(OBJ)

all: $(OBJ)

$(ROLES):
	${ADSROOT}/bin/adsql.sh < roles/$@

$(TRIGGERS):
	${ADSROOT}/bin/adsql.sh < triggers/$@

$(TABLES):
	${ADSROOT}/bin/adsql.sh < tables/$@

$(FUNCTIONS):
	${ADSROOT}/bin/adsql.sh < functions/$@

$(VIEWS):
	${ADSROOT}/bin/adsql.sh < views/$@


ADSOperator.sql: ADSViewer.sql

ADSAdmin.sql: ADSOperator.sql

runrecord.sql: jobs.sql

jobs.sql: machine.sql

runschedule.sql: jobs.sql

ScheduleNextRun.sql: CalcNextRuntime.sql 

CalcNextRuntime.sql: StringToRecs.sql sequence.sql


