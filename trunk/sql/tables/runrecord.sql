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
	status    varchar(10),
	starttime timestamp with time zone,
	endtime   timestamp with time zone
) 
WITH OIDS;
ALTER TABLE runrecord OWNER TO ads;

GRANT SELECT, REFERENCES, TRIGGER ON TABLE runrecord TO "ADSViewer";
GRANT ALL ON TABLE runrecord TO "ADSAdmin" WITH GRANT OPTION;
GRANT SELECT, REFERENCES, TRIGGER ON TABLE runrecord TO "ADSOperator";


create index RunRecord_JobID on RunRecord(JobID);
