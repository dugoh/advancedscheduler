# Copyright 2007 David Spadea
# All rights reserved.
#
# This code is release for use under the terms of the GNU General Public License, version 3.

package AdvancedScheduler;

use base qw(Exporter);
use vars qw(@EXPORT_OK);
use Data::Dumper;

use Sys::Hostname qw(hostname);

@EXPORT_OK = qw( insert_job delete_job update_job );

my (@parms);
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
		chroot
		owner
		condition
		run_window
		box_name
		job_type
	     );

sub insert_job
{
	
	my $db = AdvancedScheduler::Database->connect
		or die ($DBI::errstr);

	$db->begin_work;

	my ($jobdef) = @_;

	$$jobdef{machine} = lc ($$jobdef{machine});
	$$jobdef{owner} ||= getpwuid($<);
	$$jobdef{chroot} ||= "/";
	$$jobdef{namespace} ||= getpwuid($<);

	print "Current userid: " . getpwuid($<) . "\n";

	unless ($$jobdef{machine})
	{
		my $host = lc hostname();
		print "Warning: No machine specified, so assuming '$host'\n";
		$$jobdef{machine} = $host; # If no host given, assume current.
	}
	
	#print Dumper($jobdef);
	
	my $sql = "insert into Job (" . join (", ", sort(@parms)) . ")\n"
		.  "values (" . join(", ", map { "?" } sort @parms ) . ")\n";

	#print "Preparing sql:\n\n$sql\n\n";
	my $sth = $db->prepare($sql);

	my $rc = $sth->execute (map { $jobdef->$_ } sort @parms);

	return undef unless ($rc);

	$sql = "select SetJobStatus(?, 'IN')";

	$sth = $db->prepare($sql);

	$rc = $sth->execute ($jobdef->name);
	
	if ($rc) { $db->commit; }
	else { $db->rollback; }
	
	return $rc;
}


sub delete_job
{
	my ($jobdef) = @_;
	
	my $ads = AdvancedScheduler::Database->connect
		or die ($DBI::errstr);
	
	$ads->begin_work;
	
	my $sql = "delete from Job where namespace = ? and name = ?";

	my $sth = $ads->prepare($sql);

	my $rc = $sth->execute ($$jobdef{namespace}, $$jobdef{name});
	
	if ($rc) { $ads->commit; }
	else { $ads->rollback; }
	
	return $rc;
	
}

sub update_job
{
	my ($jobdef) = @_;
	my $ads = AdvancedScheduler::Database->connect
		or die ($DBI::errstr);

	# name and namespace are primary key fields, and cannot be changed
	# via update_job. I'm thinking a new JIL command, move_namespace:
	# or something can accomplish that. 
	my @parms = sort grep(!/ADSCOMMAND/, keys %{$jobdef}); 
	my $sql = "update job set " . join(",\n\t", map { "$_ = ?" } @parms)
		. "\nwhere namespace = ? and name = ?";

	print $sql . "\n";

	my $sth = $ads->prepare($sql);

	my @args = map{ $$jobdef{$_} }@parms;
	push @args, ($$jobdef{namespace}, $$jobdef{name});

	my $rc = $sth->execute (@args);
	
	if ($rc) { $ads->commit; }
	else { $ads->rollback; }
	
	return $rc;
	
}
