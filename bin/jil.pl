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
		namespace
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

my ($JIL, $exitcd);

while (<>)
{
	if ($_ =~ /insert_job|update_job|delete_job/)
	{
		if ($JIL)
		{
			$exitcd += &ProcessCommand($JIL);
			$JIL = undef;
		}
	}
	
	$JIL .= $_;
	
}

$exitcd += &ProcessCommand($JIL);

exit ($exitcd > 0 ? 1 : 0);

sub ProcessCommand
{
	my $def = AdvancedScheduler::JobDefinition->Parse($JIL)
		or die ('Unable to parse JIL.');
	
	# If namespace: is defined in JIL, use it. Otherwise,
	# consult the environment.
	$$def{namespace} ||= $ENV{ADSNAMESPACE};
	
	if ( $callbacks{$$def{ADSCOMMAND}} ) 
	{
		print "Issuing " . $$def{ADSCOMMAND} . " call for "
		      . join ("^", $$def{name}, $$def{namespace}) . "\n";
			      
		$ads->begin_work;
		my $rc = $callbacks{$$def{ADSCOMMAND}}->($ads, $def);
		print "Database change ";
		print $rc ? "SUCCEEDED!\n" : "FAILED!\n";
		
		if ($rc) { $ads->commit; }
		else { $ads->rollback; }
		
		return ($rc ? 0 : 1);
	}
	else
	{
		warn ("Unknown command $$def{ADSCOMMAND}\n");
		return 2;
	}
}

sub insert_job
{
	my ($db, $jobdef) = @_;

	my $sql = "insert into Job (" . join (", ", sort(@parms)) . ")\n"
		.  "values (" . join(", ", map { "?" } sort @parms ) . ")\n";

	my $sth = $db->prepare($sql);

	my $rc = $sth->execute (map { $jobdef->$_ } sort @parms);

	if ($rc)
	{
		$sth = $ads->prepare("select ScheduleNextRun(?)");
		$rc = $sth->execute($jobdef->name);
	}
	
	return $rc;
}


sub delete_job
{
	my ($db, $jobdef) = @_;

	my $sql = "delete from Job where namespace = ? and name = ?";

	my $sth = $db->prepare($sql);

	return  $sth->execute ($$jobdef{namespace}, $$jobdef{name});
}

sub update_job
{
	my ($db, $jobdef) = @_;

	# name and namespace are primary key fields, and cannot be changed
	# via update_job. I'm thinking a new JIL command, move_namespace:
	# or something can accomplish that. 
	my @parms = sort grep (!/name/, grep(!/namespace/, keys %{$jobdef})); 
	my $sql = "update job set " . join(",\n\t", map { "$_ = ?" } @parms)
		. "\nwhere namespace = ? and name = ?";

	print $sql . "\n";

	my $sth = $db->prepare($sql);

	my @args = map{ $$jobdef{$_} }@parms;
	push @args, ($$jobdef{namespace}, $$jobdef{name});

	print "Query arguments are:\n" . join("\n", @args) . "\n";
	return $sth->execute (@args);
}
