-- Table: runrecord

-- DROP TABLE runrecord;

CREATE TABLE runrecord
(
  status text,
  start_time date,
  end_time date,
  job_tid oid,
  job_oid oid
) 
WITH OIDS;
ALTER TABLE runrecord OWNER TO ads;




