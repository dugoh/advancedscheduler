/*
Copyright 2007 David Spadea
All rights reserved.

This code is release for use under the terms of the GNU General Public License, version 3.
*/

create table UpcomingTimes
(
	Name text,
	StartTime timestamp
);

create index UpcTimes_name on UpcomingTimes(name);
