/*

# Copyright 2007 David Spadea
# All rights reserved.
#
# This code is release for use under the terms of the GNU General Public License, version 3.

*/

--drop view PendingJobs
create or replace view PendingJobs
as 
	
	select job.*, sched.assigned_agent
	from RunSchedule sched
		inner join Job 
			on sched.JobID = job.JobID
	where sched.next_run <= now()
	  and job.status not in ('OI', 'OH');

/*

drop view PendingJobs

select * from PendingJobs

*/
