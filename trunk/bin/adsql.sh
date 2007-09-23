#!/bin/bash

if [ ! -z "$ADSHOST" ] ; then
	cmd=" -h $ADSHOST"
fi

if [ ! -z "$ADSUSER" ] ; then
	cmd="$cmd -U $ADSUSER"
fi

psql -d $ADSDB $cmd
