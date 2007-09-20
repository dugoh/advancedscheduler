create or replace function SetUpNextRun()
returns trigger
as $$

declare
	tsEndTime timestamp with time zone;

begin

	if TG_OP = 'UPDATE' and NEW.status = OLD.status
	then
		return NEW;
	end if;


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

		tsEndTime := CURRENT_TIMESTAMP;

	        update Job
		set Last_End_Time = tsEndTime
		where name = NEW.name;

		insert into RunRecord (JobID, Status, StartTime, EndTime)
		values (NEW.JobID, NEW.Status, NEW.Last_Start_Time, tsEndTime);
		  
                perform ScheduleNextRun(NEW.Name);
	end if;

	return NEW;

end;

$$ language 'plpgsql';

create trigger ScheduleNextRun after update on Job for each row execute procedure SetUpNextRun(); 
