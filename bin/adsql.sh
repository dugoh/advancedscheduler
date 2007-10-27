#!/bin/bash

# Copyright 2007 David Spadea
# All rights reserved.
#
# This code is release for use under the terms of the GNU General Public License, version 3.


if [ ! -z "$ADSHOST" ] ; then
	cmd=" -h $ADSHOST"
fi

if [ ! -z "$ADSUSER" ] ; then
	cmd="$cmd -U $ADSUSER"
fi

psql -d $ADSDB $cmd
