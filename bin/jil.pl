#!/usr/bin/perl

# Copyright 2007 David Spadea
# All rights reserved.
#
# This code is release for use under the terms of the GNU General Public License, version 3.

use strict;
use warnings;

use Data::Dumper;

use lib ("$ENV{ADSROOT}/lib");

use AdvancedScheduler::Database;
use AdvancedScheduler::JobDefinition;

my $ads = AdvancedScheduler::Database->connect
	or die ($DBI::errstr);

my (@parms, %parms);
@parms = qw( 
		name
		std_in_file 
		std_err_file 
		std_out_file
		machine 
		start_mins 
		start_days 
		command
	     );

my %callbacks = (
	insert_job => \&insert_job,
	update_job => \&update_job,
	delete_job => \&delete_job
);

my $JIL;
while (<>)
{
	$JIL .= $_;
}

my $def = AdvancedScheduler::JobDefinition->Parse($JIL)
	or die ('Unable to parse JIL.');

if ( $callbacks{$$def{ADSCOMMAND}} ) 
{
	my $rc = $callbacks{$$def{ADSCOMMAND}}->($ads, $def);
	print "Database change ";
	print $rc ? "SUCCEEDED!\n" : "FAILED!\n";
	exit $rc ? 0 : 1;
}
else
{
	die ("Unknown command $$def{ADSCOMMAND}\n");
}


sub insert_job
{
	my ($db, $jobdef) = @_;

	my $sql = "insert into Job (" . join (", ", sort(@parms)) . ")\n"
		.  "values (" . join(", ", map { "?" } sort @parms ) . ")\n";

	my $sth = $db->prepare($sql);

	my $rc = $sth->execute (map { $def->$_ } sort @parms) ? 1 : 0;

	$ads->SetJobStatus($$def{name}, 'IN') if ($rc); 

	return $rc;
}


sub delete_job
{
	my ($db, $jobdef) = @_;

	my $sql = "delete from Job  where name = ?";

	my $sth = $db->prepare($sql);

	return  $sth->execute ($$jobdef{name}) ? 1 : 0;
}

sub update_job
{
	my ($db, $jobdef) = @_;

	my @parms = sort grep !/name/, @parms; 
	my $sql = "update job set " . join(",\n\t", map { "$_ = ?" } @parms) . "\nwhere name = ?";

	print $sql . "\n";

	my $sth = $db->prepare($sql);

	my @args = map{ $$def{$_} }@parms;
	push @args, $$jobdef{name};

	print "Query arguments are:\n" . join("\n", @args) . "\n";
	return $sth->execute (@args) ? 1 : 0;
}
