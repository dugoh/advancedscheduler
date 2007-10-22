/*
select * from StringToRecs ( 'mo,we,fr,sa', ',');
drop function DaysToDates(text varchar)
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

		--raise info 'Delimiter is \'%\'', delim; 

		curfield := split_part( instring, delim, 1);
		counter := 1;

		while ( length(curfield) > 0 ) 
		loop

		--	raise info 'Found field string: %', curfield;
			return next curfield;
		
			counter := counter + 1;
			curfield := split_part( instring, delim, counter);


		end loop;

	end if;
end;

$$ immutable returns null on null input language plpgsql;