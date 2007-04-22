drop table RunSchedule;

create table RunSchedule
(
	  jobid 	int not null references Job(jobid)
	, next_run	timestamp
	, condition	text

	, primary key (jobid, next_run)
);