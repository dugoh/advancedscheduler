/*

Copyright 2007 David Spadea
All rights reserved.

This code is release for use under the terms of the GNU General Public License, version 3.
*/

create or replace function SetDateConditions ()
returns trigger as $$
begin

	if (   NEW.start_mins is not null
	    or NEW.start_times is not null
	    or NEW.start_days is not null )
	then 
		NEW.date_conditions := true;
	else
		NEW.date_conditions := false;
	end if;
		
end;
$$ language plpgsql;

create trigger Job_SetDateConditions before insert on Job for each row execute procedure SetDateConditions();