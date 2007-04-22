-- Table: job

-- DROP TABLE job cascade;

CREATE TABLE job
(
  jobid serial primary key,
  status text not null default 'IN',
  std_in_file text,
  std_err_file text,
  name text unique,
  machine text references Machine(name) on update cascade,
  command text,
  start_days text,
  start_mins text,
  start_times text,
  std_out_file text,
  last_start_time date,
  last_end_time date,
  condition text
) 
WITH OIDS;
ALTER TABLE job OWNER TO ads;




