/*

# Copyright 2007 David Spadea
# All rights reserved.
#
# This code is release for use under the terms of the GNU General Public License, version 3.

*/

create table maps
(
	MapName	varchar(40) not null,
	Key	varchar(100) not null,
	Value	varchar(100) not null,

	constraint MapsPK primary key (MapName, Key)
);

insert into Maps (MapName, Key, Value)
values 
('DaysOfWeek', 'sunday', '0'),
('DaysOfWeek', 'sun', '0'),
('DaysOfWeek', 'su', '0'),
('DaysOfWeek', 'monday', '1'),
('DaysOfWeek', 'mon', '1'),
('DaysOfWeek', 'mo', '1'),
('DaysOfWeek', 'tuesday', '2'),
('DaysOfWeek', 'tues', '2'),
('DaysOfWeek', 'tu', '2'),
('DaysOfWeek', 'wednesday', '3'),
('DaysOfWeek', 'wed', '3'),
('DaysOfWeek', 'we', '3'),
('DaysOfWeek', 'thursday', '4'),
('DaysOfWeek', 'thurs', '4'),
('DaysOfWeek', 'thu', '4'),
('DaysOfWeek', 'th', '4'),
('DaysOfWeek', 'friday', '5'),
('DaysOfWeek', 'fri', '5'),
('DaysOfWeek', 'fr', '5'),
('DaysOfWeek', 'saturday', '6'),
('DaysOfWeek', 'sat', '6'),
('DaysOfWeek', 'sa', '6');

insert into Maps (MapName, Key, Value)
values 
('Conditions', 's', 'SU'),
('Conditions', 'su', 'SU'),
('Conditions', 'success', 'SU'),
('Conditions', 'f', 'FA'),
('Conditions', 'fa', 'FA'),
('Conditions', 'fail', 'FA'),
('Conditions', 'failed', 'FA'),
('Conditions', 'r', 'RU'),
('Conditions', 'running', 'RU'),
('Conditions', 't', 'TE'),
('Conditions', 'te', 'TE'),
('Conditions', 'terminated', 'TE');