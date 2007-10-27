/*

Copyright 2007 David Spadea
All rights reserved.

This code is release for use under the terms of the GNU General Public License, version 3.
*/

create or replace function sequence(int, int)
returns setof int
as $$

	declare 
		first alias for $1;
		last alias for $2;
		counter int;

	begin

		for counter in first..last
		loop
			return next counter;
		end loop;

	end;

$$ returns null on null input language plpgsql;