create or replace function SetUpNextRun()
returns trigger
as $$

declare nextrun timestamp;

begin

	if NEW.status = OLD.status
	then
		return null;
	end if;

	if NEW.status = 'RU'
	then
		update Job
		set Last_Start_Time = CURRENT_TIMESTAMP
		where name = NEW.name;
	end if;

	if NEW.status in ('SU', 'FA')
	then
		update Job
		set Last_End_Time = CURRENT_TIMESTAMP
		where name = NEW.name;

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

create trigger ScheduleNextRun after update or insert on Job for each row execute procedure SetUpNextRun(); 