/*

Author: David Spadea
Date: October 2007
License: GNU GPL V3

*/

create or replace function ScheduleNextRun ( text )
returns timestamp
as $$

        declare 
                pName alias for $1;
                pJobID int4;
                nextrun timestamp;
                
        begin 
        
                if pName is null
                then
                        raise exception 'No Job Name given to schedule!';
                end if;
        
                raise notice 'Scheduling next run for job "%"', pName;
                
                select jobid
                into pJobID
                from Job
                where name = pName;
                
		delete from RunSchedule
		where JobID = pJobID;
		
		nextrun := CalcNextRuntime(pJobID);

		if nextrun is not null 
		then
			insert into RunSchedule (Machine, JobID, Next_Run, Condition)
			select Machine, JobID, nextrun, Condition
			from Job
			where JobID = pJobID;
		end if;
		
		return nextrun;
        end;
        
$$ language plpgsql;
