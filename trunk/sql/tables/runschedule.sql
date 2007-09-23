/*

# Copyright 2007 David Spadea
# All rights reserved.
#
# This code is release for use under the terms of the GNU General Public License, version 3.

*/

--drop table RunSchedule;

create table RunSchedule
(
	  machine	 varchar(255) not null references Machine(name)
	, jobid 	 int not null references Job(jobid) on delete cascade
	, next_run	 timestamp
	, condition	 text 
	, assigned_agent varchar(256) -- really, do people have 200 char hostnames?

	, primary key (jobid)
);

GRANT ALL ON TABLE runschedule TO "ADSAdmin" WITH GRANT OPTION;
GRANT SELECT, REFERENCES, TRIGGER ON TABLE runschedule TO "ADSViewer";
GRANT ALL ON TABLE runschedule TO "ADSOperator";


create index RunSched_Machine on RunSchedule(Machine);

