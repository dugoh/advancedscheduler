#!/bin/bash

. etc/ads_setupenv.sh

cat <<SYMLNKPATH

This installer can create symbolic links in another directory for you, if you are
unable to modify your PATH environment variable. 

Note that the best approach is to simply include $ADSROOT/bin in your \$PATH variable.

If you'd like to create symbolic links, please enter a destination path below. Leave it
blank if you'll set up your PATH instead.

Symlink Path:
SYMLNKPATH

read sympath

if [ ! -z "$sympath" ] ; then
	for prog in $ADSROOT/bin/*
	do
		ln -sf $prog $ADSROOT/bin/$(basename $prog | sed 's/\.[ps][lh]$//')
	done
fi

cat <<DBINSTALL

This installer can create the database objects for you. They will be created as follows:

Host     : $ADSHOST
Database : $ADSDB
UserID   : $ADSUSER

If you are simply installing the client and will be using an existing ADS database, 
you should say N here.

Install database objects? (y/n)
DBINSTALL

read instdb

if [ "$instdb" = "y" ] ; then
	echo Setting up database objects...
	cd $ADSROOT/sql && make
fi

echo Installation is complete! 

