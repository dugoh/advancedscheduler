/*
	--declare curs refcursor;

begin;
	select * from GetPendingJobs('titan');

	fetch all from "<unnamed portal 12>";
commit;
*/

create or replace function GetPendingJobs( varchar )
returns refcursor
as $$

	declare 
		machine alias for $1;
		JobID int;
		joblist refcursor;

	begin

		
		open joblist for
			select JobID 
			from RunSchedule
			where Machine = machine
			  and next_run <= now();

		return joblist;

	end;


$$ language 'plpgsql';