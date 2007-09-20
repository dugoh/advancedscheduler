--
/*
drop table Times;
select CalcNextRuntime( 23 )
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

	jobrec RECORD;

	curhr int;
	timestr text;
	counter int;
	mins	text;

	nextstart timestamp;

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

		select date_part('hour', CURRENT_TIME)
		into curhr;

		mins := split_part( jobrec.start_mins, ',', 1);
		counter := 1;

		while ( length(mins) > 0  ) 
		loop

			select lpad(mins, 2, '0' ), curhr::text || ':' || mins::text
			into mins, timestr;

			insert into UpcomingTimes (name, starttime)
			select jobrec.name, CURRENT_DATE + timestr::time;

			insert into UpcomingTimes (name, starttime)
			select jobrec.name, CURRENT_DATE + interval '1 day' + timestr::time;

			timestr := ((curhr + 1) % 24)::text || ':' || mins;

			insert into UpcomingTimes (name, starttime)
			select jobrec.name, CURRENT_DATE + timestr::time;

			insert into UpcomingTimes (name, starttime)
			select jobrec.name, CURRENT_DATE + '1 day'::interval + timestr::time;

			counter := counter + 1;
			mins := split_part( jobrec.start_mins, ',', counter);

		end loop;

	end if;

	-- start_times

	if (jobrec.start_times is not null)
	then

		timestr := split_part( jobrec.start_times, ',', 1);
		counter := 1;

		while ( length(timestr) > 0 ) 
		loop

			insert into UpcomingTimes (name,starttime)
			select jobrec.name, CURRENT_DATE + timestr::time;

			insert into UpcomingTimes (name, starttime)
			select jobrec.name, CURRENT_DATE + interval '1 day' + timestr::time;

			counter := counter + 1;
			timestr := split_part( jobrec.start_times, ',', counter);


		end loop;

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
