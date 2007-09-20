#!/bin/bash

. etc/ads_setupenv.sh

echo <<SYMLNKPATH

This installer can create symbolic links in another directory for you, if you are
unable to modify your PATH environment variable. 

Note that the best approach is to simply include $ADSROOT in your \$PATH variable.

If you'd like to create symbolic links, please enter a destination path below. Leave it
blank if you'll set up your PATH instead.

Symlink Path:
SYMLNKPATH

read $sympath

if [ ! -z "$sympath" ] ; then
	for prog in $ADSROOT/bin/*
	do
		ln -sf $prog $ADSROOT/bin/$(basename $prog | sed 's/\.[ps][lh]$//')
	done
fi

echo <<DBINSTALL

This installer can create the database objects for you. They will be created as follows:

Host     : $ADSHOST
Database : $ADSDB
UserID   : $ADSUSER

If you are simply installing the client and will be using an existing ADS database, 
you should say N here.

Install database objects? (Y/N)
DBINSTALL

read $instdb

if [ "$instdb" = "Y" ] || [ "$instdb" = "y" ] ; then
	cd sql && make
fi

echo Installation is complete! 

