/*

# Copyright 2007 David Spadea
# All rights reserved.
#
# This code is release for use under the terms of the GNU General Public License, version 3.

*/
--select * from PendingJobs
--drop view PendingJobs;
create or replace view PendingJobs
as 
	
	select job.*, sched.assigned_agent, rec.status, rec.StartTime, rec.EndTime
	from RunSchedule sched
		inner join Job 
			on sched.JobID = job.JobID
		left join RunRecord rec
			on Job.JobID = rec.JobID
	where sched.next_run <= now()
	  and (    rec.JobID is null 
	       or (rec.Current = true and rec.status not in ('OI', 'OH', 'RU')) 
	      )
	  and StartConditionsMet(job.condition) = true
	  and job.job_type = 'c'
	  and (   job.box_name is null
	       or 'RU' = (select status 
			  from Job box
				inner join RunRecord rr
					on box.JobID = rr.JobID
			  where job.Box_Name = box.Name
			    and rr.Current = true )
	      );
	  

/*

drop view PendingJobs

select * from PendingJobs
select setjobstatus('inner-box', 'RU')
*/
