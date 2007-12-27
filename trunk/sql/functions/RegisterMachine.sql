/*

Copyright 2007 David Spadea
All rights reserved.

This code is release for use under the terms of the GNU General Public License, version 3.
*/

create or replace function RegisterMachine( pName varchar(255) )
returns varchar(255)
as $$

begin

	begin 
		insert into Machine (Name) values (pName);
	exception 
		when unique_violation then
			raise notice 'Machine % is already registered.', pName;
	end;

	return pName;

end;

$$ language plpgsql;
