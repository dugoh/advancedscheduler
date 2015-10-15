# Introduction #

The installation of ADS is pretty easy, but it's not totally automated. There are a few easy steps you'll need to follow in order to get ADS up and running.

ADS is developed on Ubuntu Linux, so some of these commands may be a little different on your distribution, but you should be able to find an analog pretty easily.

# Prerequisites #

You'll need:

  * a working PERL installation with DBD::Pg installed. (The Pure Perl version should work as well. I haven't tried it with ADS specifically, but I use it elsewhere to good effect.)
  * a working Postgres installation
    * If you intend to use ADS to schedule jobs on multiple hosts, you'll need to add a 'host' line in /etc/postrgres/8.2/main/pg\_hba.conf for your network and update your listen\_address line in postgres.conf.

# Installation #

Once your environment is primed, there are a couple simple steps before running the installation.

  * Create a role (user) called 'ads' on your Postgres database.
    * **Security note:** It'll need to be a superuser, but it's only really necessary for the installation. You can turn off the login privileges after the database is set up.

```
 {0} dave@titan:~$ sudo su postgres
 [sudo] password for dave:
 postgres@titan:/home/dave$ psql
 Welcome to psql 8.2.5, the PostgreSQL interactive terminal.
 
 Type:  \copyright for distribution terms
        \h for help with SQL commands
        \? for help with psql commands
        \g or terminate with semicolon to execute query
        \q to quit 

 postgres=# create user ads superuser login;
 CREATE ROLE
 postgres=# alter user ads password 'ads';
 ALTER ROLE
 postgres=# \q
```

You should then attempt to log in using your new user ID. This accomplishes two things:

  1. It ensures that the ID works as expected.
  1. It writes an entry to your `~/.pgpass` file, which will be required by the installation. That means you'll want to do this as the user you intend to use for the installation.

```
 {0} dave@titan:~$ echo "select 'It worked'" | psql -h localhost -U ads -W
 Password for user ads: 
  ?column?  
 -----------
  It worked
 (1 row)

```

You can then use the ads user to create the database:

```
{2} dave@titan:~$ echo "create database ads" | psql -h localhost -U ads 

CREATE DATABASE
```

From this point on, it should be pretty smooth sailing. Simply adjust any settings in `$ADSROOT/etc/ads_setupenv.sh` that don't match your desired setup and run the install.sh script found in the base directory.

ADS is typically set up in its own directory, so it asks you if you'd like to create symbolic links in a more common bin directory, like /usr/bin. You don't need to, and probably shouldn't. It's better just to add the $ADSROOT/bin to your PATH.

It is a good idea to create the program symlinks within the bin directory, and the install script should do that for you. This does simple things like allowing you to call 'autorep.pl' as simply 'autorep'. There's no technical requirement for it, but it's a little nicer.

An item of note is that you only need to set up the database once. If you are installing ADS on multiple machines that will all share the same database, just set up the programs themselves. That will typically mean altering the $ADSROOT/etc/ads\_setupenv.sh and making sure agent.pl starts when the machine starts.

# Other optional setup #

## Starting the Agent.pl via Init ##

### Ubuntu ###

  * Create a symlink in `/etc/init.d` pointing to `$ADSROOT/etc/init.d/ads.sh` and then add it to the rc.d directories. It'd be something like this:

```
cd /etc/init.d
ln -s $ADSROOT/etc/init.d/ads.sh .
update-rc.d ads.sh defaults
```

ADS agent should now start when your machine starts.

### Red Hat ###

I've never done this on Red Hat, but it should be similar. Create your symlink in /etc/init.d as in the Ubuntu directions. Instead of `update-rc.d`, though, I think there's a program called `chkconfig` which will manage the `rc.d` directories. If you have Red Hat and this works for you, please update the Wiki to be a little more assertive. :-)