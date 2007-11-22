/*

# Copyright 2007 David Spadea
# All rights reserved.
#
# This code is release for use under the terms of the GNU General Public License, version 3.

*/

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
	       or (rec.Current = true and rec.status not in ('OI', 'OH')) 
	      )
	  and StartConditionsMet(job.condition) = true;

/*

drop view PendingJobs

select * from PendingJobs

*/
