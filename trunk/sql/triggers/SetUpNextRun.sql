create or replace function SetUpNextRun()
returns trigger
as $$

declare nextrun timestamp;

begin

	delete from RunSchedule
	where JobID = NEW.JobID;
	
	nextrun := CalcNextRuntime(NEW.JobID);

	if nextrun is not null 
	then
		insert into RunSchedule (Machine, JobID, Next_Run, Condition)
		select NEW.Machine, NEW.JobID, nextrun, NEW.Condition;
	end if;

	return NEW;

end;

$$ language 'plpgsql';

create trigger ScheduleNextRun after update or insert on Job for each row execute procedure SetUpNextRun(); 