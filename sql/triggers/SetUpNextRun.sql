create or replace function SetUpNextRun()
returns trigger
as $$

declare nextrun timestamp;

begin

	if TG_OP = 'UPDATE' and NEW.status = OLD.status
	then
		return NEW;
	end if;

	insert into RunRecord (JobID, Status, EventTime)
	values (NEW.JobID, NEW.Status, CURRENT_TIMESTAMP);
	

	if NEW.status in ('AC', 'IN')
	then
		update Job
		set   Last_Start_Time = NULL
		    , Last_End_Time = NULL
		where name = NEW.name;
	end if;

	if NEW.status = 'RU'
	then
		update Job
		set   Last_Start_Time = CURRENT_TIMESTAMP
		    , Last_End_Time = NULL
		where name = NEW.name;
	end if;

	if NEW.status in ('SU', 'FA')
	then
		
		update Job
		set Last_End_Time = CURRENT_TIMESTAMP
		where name = NEW.name
		  and NEW.status in ('SU', 'FA');

		delete from RunSchedule
		where JobID = NEW.JobID;
		
		nextrun := CalcNextRuntime(NEW.JobID);

		if nextrun is not null 
		then
			insert into RunSchedule (Machine, JobID, Next_Run, Condition)
			select NEW.Machine, NEW.JobID, nextrun, NEW.Condition;
		end if;

	end if;

	return NEW;

end;

$$ language 'plpgsql';

create trigger ScheduleNextRun after update on Job for each row execute procedure SetUpNextRun(); 
