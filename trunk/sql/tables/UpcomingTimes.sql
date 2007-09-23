/*
Copyright 2007 David Spadea
All rights reserved.

This code is release for use under the terms of the GNU General Public License, version 3.
*/
--drop table upcomingtimes

create table upcomingtimes
(
	Name text references job(name) on delete cascade on update cascade,
	StartTime timestamp
);

GRANT ALL ON TABLE upcomingtimes TO "ADSAdmin" WITH GRANT OPTION;
GRANT SELECT ON TABLE upcomingtimes TO "ADSViewer";
GRANT SELECT ON TABLE upcomingtimes TO "ADSOperator";

create index UpcTimes_name on upcomingtimes(name);
