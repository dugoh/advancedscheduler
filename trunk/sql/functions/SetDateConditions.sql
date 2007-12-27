/*

Copyright 2007 David Spadea
All rights reserved.

This code is release for use under the terms of the GNU General Public License, version 3.
*/

create or replace function SetDateConditions ()
returning trigger as $$

	update NEW
	set date_conditions = case
		when NEW.start_mins is not null
		  or NEW.start_times is not null
		  or NEW.

$$