/*

select GetPendingJobs('titan', '  ');

select * from RunSchedule

drop function GetPendingJobs(varchar, varchar)
*/

create or replace function GetPendingJobs( varchar )
returns setof record
as $$

	select *
	from RunSchedule sched
		inner join Job 
			on sched.JobID = job.JobID
	where sched.Machine = $1
	  and next_run <= now()
	  and assigned_agent is null;

$$ language SQL;