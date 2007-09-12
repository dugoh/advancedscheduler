#!/usr/bin/perl

# Copyright 2007 David Spadea
# All rights reserved.
#
# This code is release for use under the terms of the GNU General Public License, version 3.

use strict;
use warnings;

use Data::Dumper;

use lib qw(../lib);

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

my $JIL;
while (<>)
{
	$JIL .= $_;
}

my $def = AdvancedScheduler::JobDefinition->Parse($JIL)
	or die ('Unable to parse JIL.');

my $sql = "insert into Job (" . join (", ", sort(@parms)) . ")\n"
	.  "values (" . join(", ", map { "?" } sort @parms ) . ")\n";

print $sql;
my $sth = $ads->prepare($sql);

print $sth->execute (map { $def->$_ } sort @parms) ? "SUCCESS" : "FAILURE";
print "\n";

$ads->SetJobStatus($def->name, 'IN'); 
