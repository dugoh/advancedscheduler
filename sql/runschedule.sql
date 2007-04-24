--drop table RunSchedule;

create table RunSchedule
(
	  jobid 	int not null references Job(jobid) on delete cascade
	, next_run	timestamp
	, condition	text 

	, primary key (jobid)
);
