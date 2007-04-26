/*

select GetPendingJobs('titan');

select * from RunSchedule

drop function GetPendingJobs(varchar)
*/

create or replace function GetPendingJobs( varchar )
returns setof int
as $$

		select JobID
		from RunSchedule
		where Machine = $1
		and next_run <= now();

$$ language 'sql';