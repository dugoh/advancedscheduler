/*

# Copyright 2007 David Spadea
# All rights reserved.
#
# This code is release for use under the terms of the GNU General Public License, version 3.

*/

-- Table: machine

-- DROP TABLE machine cascade;

CREATE TABLE machine
(
  name varchar(255) primary key
) 
WITH OIDS;
ALTER TABLE machine OWNER TO ads;

GRANT ALL ON TABLE machine TO "ADSAdmin" WITH GRANT OPTION;
GRANT SELECT ON TABLE machine TO "ADSViewer";
GRANT REFERENCES, TRIGGER ON TABLE machine TO "ADSViewer" WITH GRANT OPTION;
GRANT SELECT ON TABLE machine TO "ADSOperator";
GRANT REFERENCES, TRIGGER ON TABLE machine TO "ADSOperator" WITH GRANT OPTION;




