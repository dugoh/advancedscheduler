/*

Copyright 2007 David Spadea
All rights reserved.

This code is release for use under the terms of the GNU General Public License, version 3.
*/

create or replace function GetConfig ( pModule varchar(100), pName varchar(100), fatal bool)
returns varchar
as $$

declare 
	result varchar(4000);
begin
	select value
	into result
	from config
	where module = pModule
	  and name = pName;

	if NOT FOUND
	then

		if (fatal)
		then
			raise exception 'Unable to find configuration: module=% and name = %', pModule, pName;
		else
			raise notice 'Unable to find configuration: module=% and name = %', pModule, pName;
		end if;

	end if;

	return result;

end;	

$$ stable language plpgsql;