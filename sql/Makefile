#!/usr/bin/make

SETUP= plperl.sql plpgsql.sql
ROLES=ADSAdmin.sql ADSViewer.sql ADSOperator.sql
TRIGGERS=
TABLES= jobs.sql \
	runrecord.sql \
	machine.sql \
	runschedule.sql \
	UpcomingTimes.sql \
	maps.sql
FUNCTIONS=	CalcNextRuntime.sql \
		ScheduleNextRun.sql \
		StringToRecs.sql \
		sequence.sql \
		StartConditionsMet.sql \
		ParseCondition.sql \
		SetJobStatus.sql \
                RegisterMachine.sql
                
VIEWS=PendingJobs.sql \
      CurrentStatus

OBJ=$(ROLES) $(TRIGGERS) $(TABLES) $(FUNCTIONS) $(VIEWS)

.PHONY: $(OBJ)

all: $(OBJ)

$(OBJ): $(SETUP)

$(SETUP): 
	echo Setup: $@
	${ADSROOT}/bin/adsql.sh < setup/$@ || exit 1

$(ROLES):
	echo Role: $@
	${ADSROOT}/bin/adsql.sh < roles/$@ || exit 1

$(TRIGGERS): $(TABLES) 
	echo Trigger: $@
	${ADSROOT}/bin/adsql.sh < triggers/$@ || exit 1

$(TABLES): $(ROLES)
	echo Table: $@
	${ADSROOT}/bin/adsql.sh < tables/$@ || exit 1

$(FUNCTIONS): $(TABLES)
	echo Function: $@
	${ADSROOT}/bin/adsql.sh < functions/$@ || exit 1

$(VIEWS): $(TABLES)
	echo View: $@
	${ADSROOT}/bin/adsql.sh < views/$@ || exit 1


ADSOperator.sql: ADSViewer.sql

ADSAdmin.sql: ADSOperator.sql

runrecord.sql: jobs.sql

jobs.sql: machine.sql

runschedule.sql: jobs.sql

ScheduleNextRun.sql: CalcNextRuntime.sql 

CalcNextRuntime.sql: StringToRecs.sql sequence.sql

PendingJobs.sql: StartConditionsMet.sql


