/*

# Copyright 2007 David Spadea
# All rights reserved.
#
# This code is release for use under the terms of the GNU General Public License, version 3.

*/

-- Table: runrecord

-- DROP TABLE runrecord;

CREATE TABLE runrecord
( 
	jobid int not null references job(jobid) on delete cascade on update cascade, 
	status varchar(10),
	eventtime timestamp
) 
WITH OIDS;
ALTER TABLE runrecord OWNER TO ads;
