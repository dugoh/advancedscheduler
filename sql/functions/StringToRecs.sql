/*

# Copyright 2007 David Spadea
# All rights reserved.
#
# This code is release for use under the terms of the GNU General Public License, version 3.


*/


create or replace function StringToRecs ( text, varchar )
returns setof text
as $$

declare

	instring	alias for $1;
	delim		alias for $2;
	curfield	text;
	counter int;

begin	
	if (instring is not null)
	then

		curfield := split_part( instring, delim, 1);
		counter := 1;

		while ( length(curfield) > 0 ) 
		loop

			return next curfield;
		
			counter := counter + 1;
			curfield := split_part( instring, delim, counter);


		end loop;

	end if;
end;

$$ immutable returns null on null input language plpgsql;
