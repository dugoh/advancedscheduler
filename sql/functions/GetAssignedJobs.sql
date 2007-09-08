create or replace function GetAssignedJobs ( varchar, varchar )
returns setof record 
as $$

declare 
	job record;
begin
	for job in 
		select JobID
		from RunSchedule
		where Machine = $1
		  and next_run <= now()
		  and assigned_agent != $2
	loop
		return next job;
	end loop;
end;

$$ language plpgsql;

-- select * from GetAssignedJobs('titan', 'meh')