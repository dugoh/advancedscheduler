#!/bin/bash

# Copyright 2007 David Spadea
# All rights reserved.
#
# This code is release for use under the terms of the GNU General Public License, version 3.

if [ "$1" = "--help" ] ; then

cat <<"HEREDOC"

This script can be invoked as follows:

 Pipe in SQL from STDIN:

   cat myquery.sql | adsql
   echo 'select CURRENT_TIMESTAMP' | adsql
   adsql < myquery.sql

 OR

 Supply the query as argument(s) to the command.

   adsql select JobID, StartTime, EndTime from RunRecord
   adsql 'select * from Job'

BEWARE SHELL EXPANSIONS!

 Note that the second example above has the query in quotes. This is
 because of the '*' in the query. This will get expanded by the shell,
 and the query that adsql actually sees will contain the names of every
 file in the current directory!

 Alternatives would be:

   adsql select \* from Job
   adsql select '*' from Job

 ...basically anything that keeps the shell from expanding the * before
 passing it into adsql.

HEREDOC

fi

sql="$*"

if [ ! -z "$ADSHOST" ] ; then
	cmd=" -h $ADSHOST"
fi

if [ ! -z "$ADSUSER" ] ; then
	cmd="$cmd -U $ADSUSER"
fi

if [ ! -z "$sql" ] ; then
    echo "$sql" | psql -d $ADSDB $cmd
else
    psql -d $ADSDB $cmd
fi

