--drop table RunSchedule;

create table RunSchedule
(
	  machine	varchar(255) not null references Machine(name)
	, jobid 	int not null references Job(jobid) on delete cascade
	, next_run	timestamp
	, condition	text 

	, primary key (jobid)
);

create index RunSched_Machine on RunSchedule(Machine);