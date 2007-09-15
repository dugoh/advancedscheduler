/*
Copyright 2007 David Spadea
All rights reserved.

This code is release for use under the terms of the GNU General Public License, version 3.
*/
--drop table upcomingtimes

create table UpcomingTimes
(
	Name text references job(name) on delete cascade on update cascade,
	StartTime timestamp
);

create index UpcTimes_name on UpcomingTimes(name);
