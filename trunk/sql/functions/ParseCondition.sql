/*

# Copyright 2007 David Spadea
# All rights reserved.
#
# This code is release for use under the terms of the GNU General Public License, version 3.

*/

create or replace function ParseCondition(cond in text, condition out text, job out text)
returns record
as $$

	my $cond = shift;

	my ($condition, $job) = $cond =~ /([a-z]+)\(([a-z0-9_-]+)\)/i;

	return { condition => $condition, job => $job };

$$ language plperl;