#!/usr/bin/perl 

# Copyright 2007 David Spadea
# All rights reserved.
#
# This code is release for use under the terms of the GNU General Public License, version 3.


use lib ("$ENV{ADSROOT}/lib");

use strict;
use warnings;

use AdvancedScheduler::Database;

use Getopt::Long;
use Data::Dumper;

my %opts;


GetOptions(

# Report specification
	'J=s' => \$opts{jobname},
	'job=s' => \$opts{jobname},

	'q' => \$opts{jobdef},
	'jobdef' => \$opts{jobdef}, # default to JIL

# Output options
	'format' => \$opts{format} # xml, jil, yaml
);

my $db = AdvancedScheduler::Database->connect_cached;


unless ($opts{jobname})
{
	print "You must specify a job name using --job= or -J\n";
	exit 1;
}


my $rc;
if ( $opts{jobdef} )
{
	$rc = &ShowJobDefs( $db, \%opts );
}
else
{
	$rc = &ShowRunRecords ( $db, \%opts );
}

exit $rc;

sub ShowJobDefs
{
	my ($db, $opts) = @_;

	my $jobpat = $$opts{jobname};
	my $fmt = $$opts{format};

	my $sql =<<SQL;

	select 
                name as insert_job,
                namespace,
                command,
                condition,
                machine,
                start_days,
                start_mins,
                start_times,
                std_err_file,
                std_in_file,
                std_out_file
	from Job
	where name like ?
	order by name -- will need to order by box,name when that's implemented
	
SQL

	my $sth = $db->prepare($sql);
	$sth->execute($jobpat)
		or die ($DBI::errstr);
	
	while (my $jd = $sth->fetchrow_hashref)
	{
		print "\n/* -------  $$jd{insert_job}  ------- */\n\n";

		# Always insert_job, always first
		print "insert_job: $$jd{insert_job}\n";

		{
			no warnings;
			map {
				print join(": ", $_, $$jd{$_}) . "\n";
			} sort grep !/insert_job/, @{$sth->{NAME_lc}};
		}
	}
	
	$sth->finish;
	return 0;
}

sub ShowRunRecords
{ 
	my ($db, $opts) = @_;

	my $jobpat = $$opts{jobname};
	my $format = $$opts{format};

	my $sql =<<SQL;

	select name,
	       last_start_time,
	       last_end_time,
	       status
	from job
	where name like ?
	order by name

SQL

	my $fmt = "%-35s %-8s %-30s %-30s\n";
	print sprintf($fmt, "Job Name", "Status", "Last Start", "Last End");
	print "-" x 35 . " " . "-" x 8 . " " . "-" x 30 . " " . "-" x 30 . "\n";

	my $sth = $db->prepare($sql);
	$sth->execute($jobpat);

	while (my $rec = $sth->fetchrow_hashref)
	{
		{
			no warnings;
			print sprintf($fmt, $$rec{name}, $$rec{status}, $$rec{last_start_time}, $$rec{last_end_time});
		}
	}

	print "\n";

	return 0;
}




