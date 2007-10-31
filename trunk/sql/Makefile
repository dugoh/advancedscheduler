#!/usr/bin/make

SETUP= plperl.sql plpgsql.sql
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
		sequence.sql \
		StartConditionsMet.sql
VIEWS=PendingJobs.sql

OBJ=$(ROLES) $(TRIGGERS) $(TABLES) $(FUNCTIONS) $(VIEWS)

.PHONY: $(OBJ)

all: $(OBJ)

$(OBJ): $(SETUP)

$(SETUP): 
	${ADSROOT}/bin/adsql.sh < setup/$@ || exit 1

$(ROLES):
	${ADSROOT}/bin/adsql.sh < roles/$@ || exit 1

$(TRIGGERS): $(TABLES)
	${ADSROOT}/bin/adsql.sh < triggers/$@ || exit 1

$(TABLES): $(ROLES)
	${ADSROOT}/bin/adsql.sh < tables/$@ || exit 1

$(FUNCTIONS): $(TABLES)
	${ADSROOT}/bin/adsql.sh < functions/$@ || exit 1

$(VIEWS): $(TABLES)
	${ADSROOT}/bin/adsql.sh < views/$@ || exit 1


ADSOperator.sql: ADSViewer.sql

ADSAdmin.sql: ADSOperator.sql

runrecord.sql: jobs.sql

jobs.sql: machine.sql

runschedule.sql: jobs.sql

ScheduleNextRun.sql: CalcNextRuntime.sql 

CalcNextRuntime.sql: StringToRecs.sql sequence.sql

PendingJobs.sql: StartConditionsMet.sql
