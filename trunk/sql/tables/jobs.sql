/*

# Copyright 2007 David Spadea
# All rights reserved.
#
# This code is release for use under the terms of the GNU General Public License, version 3.

*/

-- Table: job

-- DROP TABLE job cascade;

CREATE TABLE job
(
  namespace varchar(30),
  name text unique,
  machine varchar(255) references Machine(name) on update cascade,
  jobid serial unique,
  status varchar(10) not null default 'IN',
  std_in_file text,
  std_err_file text,
  command text,
  start_days text,
  start_mins text,
  start_times text,
  std_out_file text,
  last_start_time timestamp with time zone,
  last_end_time timestamp with time zone,
  condition text,

  constraint JobPK primary key (namespace, name)
) 
WITH OIDS;
ALTER TABLE job OWNER TO ads;


GRANT ALL ON TABLE job TO ads;
GRANT ALL ON TABLE job TO "ADSOperator";
GRANT SELECT, REFERENCES, TRIGGER ON TABLE job TO "ADSViewer";
GRANT ALL ON TABLE job TO "ADSAdmin" WITH GRANT OPTION;
