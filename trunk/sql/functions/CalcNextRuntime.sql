--
/*
drop table Times;
select CalcNextRuntime( 20 )
select * from UpcomingTimes
select * from job
*/
-- select * from Times
-- 
-- drop function CalcNextRuntime(int)
-- echo ('meh')



create or replace function CalcNextRuntime( int)
returns timestamp
as $$

declare
	pJobID alias for $1;
	counter int;
	jobrec RECORD;
	nextstart timestamp;
	hour int;

begin


	-- Collect scheduling information

	select 
	into jobrec *
	from Job
	where JobID = pJobID;

	delete from UpcomingTimes where name = jobrec.name;
	/* 

	For the time being, we simply figure out all possible start times for the current and next hour, and
	consider them for the current and next day. We then take the minimum of that list which is greater than 
	the current time. This allows scheduling over midnight.

	To implement start_days, we'll need to consider whether current_day is listed, and when the
	next current_day is. Instead of adding '1 day', we'd add (next day - current day) days. Should be straightforward.

	*/


	-- start_mins processing
	
	if (jobrec.start_mins is not null) 
	then 
		-- calc times for today and every day in the coming week
		for counter in 0..7 
		loop
			for hour in 0..23
			loop
				-- all start_mins for current hour
				insert into UpcomingTimes (name, starttime)
				-- all start_mins for next date/current hour
				select jobrec.name, CURRENT_DATE + (hour::varchar || ':' || lpad(mins, 2, '0'))::time + (counter::varchar || ' day')::interval
				from StringToRecs(jobrec.start_mins, ',') as mins;
			end loop;
		end loop;

	end if;

	-- start_times

	if (jobrec.start_times is not null)
	then

		-- start times for today and the following week
		for counter in 0..7 
		loop
			insert into UpcomingTimes(Name, StartTime)
			select jobrec.name, CURRENT_DATE + (counter::varchar || ' day')::interval + times::time
			from StringToRecs(jobrec.start_times, ',') times;
		end loop;
		
	end if;

	if ( jobrec.start_days is not null )
	then
		delete 
		from UpcomingTimes 
		where Name = jobrec.Name
		  and extract(dow from StartTime) not in (
			select maps.value
			from StringToRecs(jobrec.start_days) dow
				inner join maps
					on maps.key = lower(dow)
			where maps.MapName = 'DaysOfWeek'
		  );
	end if;

	select min(starttime)
	into nextstart
	from UpcomingTimes
	where starttime >= now()
	  and name = jobrec.name;

	raise notice 'Next scheduled start for % is %', jobrec.name, nextstart; 

	return nextstart;

end;

$$ language 'plpgsql';
