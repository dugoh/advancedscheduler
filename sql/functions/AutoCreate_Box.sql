/*

Copyright 2007 David Spadea
All rights reserved.

This code is release for use under the terms of the GNU General Public License, version 3.
*/

create or replace function AutoCreate_Box()
returns trigger
as $$

declare 
	do_autocreate	varchar(1);
	box_exists 	bool;
	
begin

	if NEW.job_type != 'c' 
	then 
		return NEW; 
	end if;

	do_autocreate := GetConfig('ads', 'auto_create_boxes', false);

	raise debug 'doing select 1 from job';
	
	select true
	into box_exists
	from Job
	where job.namespace = NEW.namespace
	  and job.name = NEW.box_name
	  and job.job_type = 'b';

	raise debug 'checking not found';
	
	if coalesce(box_exists, false) != true
	then

		raise debug 'inside not found. dac = %', do_autocreate;
	
		if lower(do_autocreate) = 'y'
		then
			raise debug 'inside do_autocreate=y';
			
			raise debug 'Box % not found in namespace %. It will be automatically created.', NEW.box_name, NEW.namespace;

			insert into Job ( namespace, name, job_type )
			values ( NEW.namespace, NEW.box_name, 'b');

		else

			raise debug 'inside do_autocreate != y';
			
			raise exception 'Box % not found in namespace %, and autocreate_boxes option not set. You need to explicitly create the box.'
				    , NEW.box_name, NEW.namespace;

		end if;
		
	end if;

	return NEW;
end;

$$ language plpgsql;

create trigger AutocreateMissingBoxes before insert on Job for each row execute procedure AutoCreate_Box();
