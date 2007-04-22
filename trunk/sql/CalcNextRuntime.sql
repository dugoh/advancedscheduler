--select CalcNextRuntime( '10,20,30,55', '5:00', 'th' )
-- select * from Times
-- drop table Times
-- drop function CalcNextRuntime(text, text, text)
create or replace function CalcNextRuntime( text, text, text)
returns timestamp
as $$

declare
	start_mins  alias for $1;
	start_times  alias for $2;
	start_days  alias for $3;

	curhr int;
	timestr text;
	counter int;
	mins	text;

	nextstart timestamp;

begin

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

			insert into times (starttime)
			select CURRENT_DATE + interval '1 day' + timestr::time;

			timestr := ((curhr + 1) % 24)::text || ':' || mins;

			insert into times (starttime)
			select CURRENT_DATE + timestr::time;

			insert into times (starttime)
			select CURRENT_DATE + '1 day'::interval + timestr::time;

			counter := counter + 1;
			mins := split_part( start_mins, ',', counter);

		end loop;

	end if;

	select min(starttime)
	into nextstart
	from Times
	where starttime > now();


	return nextstart;

end;

$$ language 'plpgsql';
