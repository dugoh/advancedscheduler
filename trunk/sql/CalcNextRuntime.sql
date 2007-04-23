--select CalcNextRuntime( 14 )
-- select * from Times
-- drop table Times
-- drop function CalcNextRuntime(text)
-- echo ('meh')
create or replace function CalcNextRuntime( int)
returns timestamp
as $$

declare
	JobID alias for $1;

	jobname text;
	start_mins  text;
	start_times  text;
	start_days  text;

	curhr int;
	timestr text;
	counter int;
	mins	text;

	nextstart timestamp;

begin

	-- Collect scheduling information

	raise notice 'Determing scheduling information for jobid: %', JobID;

	select name, start_mins, start_times, start_days
	into jobname, start_mins, start_times, start_days
	from Job
	where JobID = JobID;

	raise notice 'name: % start_mins: %  start_times: %   start_days: %', 
		     jobname, start_mins, start_times, start_days;

	/* 

	For the time being, we simply figure out all possible start times for the current and next hour, and
	consider them for the current and next day. We then take the minimum of that list which is greater than 
	the current time. This allows scheduling over midnight.

	To implement start_days, we'll need to consider whether current_day is listed, and when the
	next current_day is. Instead of adding '1 day', we'd add (next day - current day) days. Should be straightforward.

	*/

	create temporary table times
	(
		starttime timestamp
	);

	-- start_mins processing
	
	if (start_mins is not null) 
	then 

		select date_part('hour', CURRENT_TIME)
		into curhr;

		mins := split_part( start_mins, ',', 1);
		counter := 1;

		while ( length(mins) > 0  ) 
		loop

			select lpad(mins, 2, '0' ), curhr::text || ':' || mins::text
			into mins, timestr;

			insert into times (starttime)
			select CURRENT_DATE + timestr::time;

			raise notice 'start_mins 1: %', timestr;

			insert into times (starttime)
			select CURRENT_DATE + interval '1 day' + timestr::time;

			raise notice 'start_mins 2: %', timestr;

			timestr := ((curhr + 1) % 24)::text || ':' || mins;

			insert into times (starttime)
			select CURRENT_DATE + timestr::time;

			raise notice 'start_mins 3: %', timestr;

			insert into times (starttime)
			select CURRENT_DATE + '1 day'::interval + timestr::time;

			raise notice 'start_mins 4: %', timestr;

			counter := counter + 1;
			mins := split_part( start_mins, ',', counter);

		end loop;

	end if;

	-- start_times

	if (start_times is not null)
	then

		timestr := split_part( start_times, ',', 1);
		counter := 1;

		while ( length(timestr) > 0 ) 
		loop

			insert into times (starttime)
			select CURRENT_DATE + timestr::time;

			raise notice 'start_times 1: %', timestr;

			insert into times (starttime)
			select CURRENT_DATE + interval '1 day' + timestr::time;

			raise notice 'start_times 2: %', timestr;

			counter := counter + 1;
			timestr := split_part( start_times, ',', counter);


		end loop;

	end if;

	select min(starttime)
	into nextstart
	from Times
	where starttime >= now();


	return nextstart;

end;

$$ language 'plpgsql';
