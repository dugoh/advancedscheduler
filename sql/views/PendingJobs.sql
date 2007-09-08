create or replace view PendingJobs
as 
	
	select job.*
	from RunSchedule sched
		inner join Job 
			on sched.JobID = job.JobID
	where next_run <= now()
	  and assigned_agent is null;

/*

select * from PendingJobs

*/