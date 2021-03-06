/*

# Copyright 2007 David Spadea
# All rights reserved.
#
# This code is release for use under the terms of the GNU General Public License, version 3.

*/
--drop function SetJobStatus(text, varchar)



create or replace function SetJobStatus(pJobName text, pStatus varchar(10))
returns void
as $$

declare
	tsStartTime timestamp with time zone;
	tsEndTime timestamp with time zone;
        CurJob record;

begin

	select JobID, Job_Type, Condition
	into CurJob
	from Job
	where Name = pJobName;

	if pStatus in ('AC', 'IN')
	then
		tsStartTime := NULL;
		tsEndTime := NULL;

		delete from RunSchedule where JobID = CurJob.JobID;

		insert into RunSchedule (machine, jobid, next_run, condition)
		select machine, jobid, CURRENT_TIMESTAMP, condition
		from Job
		where JobID = CurJob.JobID;

                if CurJob.Job_Type = 'b' and pStatus = 'AC'
                then
                    perform SetJobStatus(Name, 'AC')
                    from Job
                    where Box_Name = pJobName;

                    if StartConditionsMet(CurJob.condition) = true
                    then
			perform SetJobStatus(pJobName, 'RU');
		    end if;
		    
                end if;

                
                
	end if;

	if pStatus = 'RU'
	then
		tsStartTime := CURRENT_TIMESTAMP;
		tsEndTime := NULL;

	end if;


	/* In Autosys, sometimes a job will fail to start, or will fail. The job
	   may then be run by hand, and a sendevent used to set the status to SU. 
	   In that case, the StartTime behavior is a bit undefined, in my mind. 

	   Do we use the time the job started originally and then use CURRENT_TIMESTAMP
	   for the end time? Do we use a NULL start time and current end time? 

	   I think it makes more sense to use the original start time, if available, and 
	   the end time as of the sendevent. That at least shows the duration that the job
	   took to complete successfully, as opposed to having no duration information at all. 

	   I honestly don't know how Autosys handles this, but I think this is the way I want ADS
	   to work.
	*/

	if pStatus in ('SU', 'FA', 'TE')
	then 
		select StartTime
		into tsStartTime
		from RunRecord
		where JobID = CurJob.JobID
		  and Current = true; 

		tsEndTime := CURRENT_TIMESTAMP;

	end if;

	-- Assuming that we're running inside of a transaction. 
	-- TODO: Really should put some sort of a check/warn here to catch developer error.
	
	update RunRecord 
	set Current = false
	where JobID = CurJob.JobID 
	  and Current = true;
	  
	insert into RunRecord (JobID, Status, StartTime, EndTime)
	select CurJob.JobID, pStatus, tsStartTime, tsEndTime;

	-- Initial or terminal states
	if (pStatus in ('IN', 'SU', 'FA', 'TE'))
	then
		perform ScheduleNextRun(pJobName);
	end if;


end;

$$ language 'plpgsql';
