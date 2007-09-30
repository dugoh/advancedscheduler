#!/bin/bash
# Uncomment to try using some common Autosys environment variables
#export AUTOSYS_COMPAT=1

export ADSHOST=localhost
export ADSUSER=ads
export ADSPASSWD=ads
export ADSDB=ads
export ADSROOT=/home/dave/dev/advancedscheduler
export ADSNAMESPACE=$USERNAME 
export ADSLOG=$ADSROOT/log
export ADSJOBLOG=$ADSLOG/jobs
export PATH=$PATH:$ADSROOT/bin

export PGPASSWORD=$ADSPASSWD

# Autosys compatability

if [ "$AUTOSYS_COMPAT" = "1" ] ; then

	if [ ! -z "$AUTOSERV" ] 
	then
		export ADSNAMESPACE=$AUTOSERV
	fi

fi
