#!/usr/bin/perl

# Copyright 2007 David Spadea
# All rights reserved.
#
# This code is release for use under the terms of the GNU General Public License, version 3.

use strict;
use warnings;

use Data::Dumper;
use Sys::Hostname;

use lib ("$ENV{ADSROOT}/lib");

use AdvancedScheduler qw(insert_job update_job delete_job);
use AdvancedScheduler::Database;
use AdvancedScheduler::JobDefinition;

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
		      . join ("::", $$def{namespace}, $$def{name}) . "\n";
			      
		my $rc = $callbacks{$$def{ADSCOMMAND}}->($def);
		print "Database change ";
		print $rc ? "SUCCEEDED!\n" : "FAILED!\n";
		
		return ($rc ? 0 : 1);
	}
	else
	{
		warn ("Unknown command $$def{ADSCOMMAND}\n");
		return 2;
	}
}
