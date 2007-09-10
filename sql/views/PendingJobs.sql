create or replace view PendingJobs
as 
	
	select job.*
	from RunSchedule sched
		inner join Job 
			on sched.JobID = job.JobID
	where sched.next_run <= now()
      and sched.assigned_agent is null 
      and job.status = 'AC';

/*

select * from PendingJobs

*/