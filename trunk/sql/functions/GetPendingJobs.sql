/*

select GetPendingJobs('titan', '  ');

select * from RunSchedule

drop function GetPendingJobs(varchar, varchar)
*/

create or replace function GetPendingJobs( varchar, varchar )
returns setof int
as $$

		select JobID
		from RunSchedule
		where Machine = $1
		  and next_run <= now()
		  and assigned_agent != $2;

$$ language SQL;