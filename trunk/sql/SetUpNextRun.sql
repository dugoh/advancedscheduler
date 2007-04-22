create or replace function SetUpNextRun()
returns trigger
as $$

declare nextrun timestamp;

begin

	delete from RunSchedule
	where JobID = NEW.JobID;
	
	nextrun := CalcNextRuntime(NEW.start_mins, NEW.start_times, NEW.start_days);

	insert into RunSchedule (JobID, Next_Run, Condition)
	select NEW.JobID, nextrun, NEW.Condition;

	return NEW;

end;

$$ language 'plpgsql';

create trigger ScheduleNextRun after update or insert on Job for each row execute procedure SetUpNextRun(); 