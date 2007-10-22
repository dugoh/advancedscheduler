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

	create temporary table UpcomingDays
	as
		select *
		from DaysToDates( jobrec.start_days);



	-- start_mins processing
	
	if (jobrec.start_mins is not null) 
	then 

		-- all start_mins for current date/current hour
		insert into UpcomingTimes (name, starttime)
		select jobrec.name, CURRENT_DATE + (date_part('hour', CURRENT_TIME) || ':' || lpad(mins, 2, '0'))::time
		from StringToRecs(jobrec.start_mins, ',') as mins

		union all

		-- all start_mins for next date/current hour
		select jobrec.name, CURRENT_DATE + (date_part('hour', CURRENT_TIME) || ':' || lpad(mins, 2, '0'))::time + interval '1 day'
		from StringToRecs(jobrec.start_mins, ',') as mins
		
		union all

		-- all start_mins for current date/next hour
		select jobrec.name, CURRENT_DATE + (((date_part('hour', CURRENT_TIME)::int + 1) % 24) || ':' || lpad(mins, 2, '0'))::time 
		from StringToRecs(jobrec.start_mins, ',') as mins
		
		union all 

		-- all start_mins for next date / next hour
		select jobrec.name, CURRENT_DATE + (((date_part('hour', CURRENT_TIME)::int + 1) % 24) || ':' || lpad(mins, 2, '0'))::time + interval '1 day'
		from StringToRecs(jobrec.start_mins, ',') as mins;


	end if;

	-- start_times

	if (jobrec.start_times is not null)
	then

		insert into UpcomingTimes(Name, StartTime)
		select jobrec.name, CURRENT_DATE + times::time
		from StringToRecs(jobrec.start_times, ',') times

		union all

		select jobrec.name, CURRENT_DATE + interval '1 day' + times::time
		from StringToRecs(jobrec.start_times, ',') times;

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
