/*

# Copyright 2007 David Spadea
# All rights reserved.
#
# This code is release for use under the terms of the GNU General Public License, version 3.

*/

/*
drop function ParseRunWindow(text, out time, out time)
select * from ParseRunWindow('21:00-16:00')
*/

create or replace function ParseRunWindow( in text, start_time out time, end_time out time)
returns record
as $$

	my $run_window = shift;

	my ($start, $end) = $run_window =~ /([0-9]{1,2}:[0-9]{2})\s*\-\s*([0-9]{1,2}:[0-9]{2})/i;

	return { start_time => $start, end_time => $end };

$$ stable returns null on null input language plperl;