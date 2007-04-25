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




