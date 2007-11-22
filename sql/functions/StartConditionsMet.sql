/*

# Copyright 2007 David Spadea
# All rights reserved.
#
# This code is release for use under the terms of the GNU General Public License, version 3.

*/

--select StartConditionsMet('s(sleep)')

create or replace function StartConditionsMet( text )
returns bool
as $$

declare 
	conds alias for $1;
	condition varchar(20);
	jobname text;
	condsmet bool;
	truecond bool;

	cur_cond cursor (cds text) is 
		select * from StringToRecs(cds, ' and ') conditions;
		

begin

	open cur_cond (conds);

	condsmet := true;

	loop

		fetch cur_cond into condition;
    
		if not found then
			exit;  -- exit loop
		end if;

		select true
		into truecond
		from ParseCondition(condition) c
			inner join maps 
				on maps.key = c.condition
			inner join job
				on c.job = job.name
			inner join RunRecord rec
				on job.JobID = rec.JobID
		where rec.status = maps.value
		  and rec.Current = true
		  and maps.mapname = 'Conditions';

		if truecond is null
		then
			condsmet := false;
			--raise notice '% is not true. Not checking any more.', condition;
			exit;
		--else
			--raise notice '% is true', condition;
		end if;

	end loop;

	close cur_cond;
	return condsmet;

	
end;

$$ language plpgsql;