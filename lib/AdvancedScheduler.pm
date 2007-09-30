package AdvancedScheduler;

use base qw(Exporter);
use vars qw(@EXPORT_OK);
use Data::Dumper;

@EXPORT_OK = qw( insert_job delete_job update_job );

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

sub insert_job
{
	
	my $ads = AdvancedScheduler::Database->connect
		or die ($DBI::errstr);

	my ($db, $jobdef) = @_;

	print Dumper($jobdef);

	$$jobdef{machine} = lc ($$jobdef{machine});

	unless ($$jobdef{machine})
	{
		my $host = lc hostname();
		print "Warning: No machine specified, so assuming '$host'\n";
		$$jobdef{machine} = $host; # If no host given, assume current.
	}
	
	my $sql = "insert into Job (" . join (", ", sort(@parms)) . ")\n"
		.  "values (" . join(", ", map { "?" } sort @parms ) . ")\n";

	print "Preparing sql:\n\n$sql\n\n";
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
	
	my $ads = AdvancedScheduler::Database->connect
		or die ($DBI::errstr);

	my $sql = "delete from Job where namespace = ? and name = ?";

	my $sth = $db->prepare($sql);

	return  $sth->execute ($$jobdef{namespace}, $$jobdef{name});
}

sub update_job
{
	my ($db, $jobdef) = @_;
	my $ads = AdvancedScheduler::Database->connect
		or die ($DBI::errstr);

	# name and namespace are primary key fields, and cannot be changed
	# via update_job. I'm thinking a new JIL command, move_namespace:
	# or something can accomplish that. 
	my @parms = sort grep(!/ADSCOMMAND/, grep (!/name/, grep(!/namespace/, keys %{$jobdef}))); 
	my $sql = "update job set " . join(",\n\t", map { "$_ = ?" } @parms)
		. "\nwhere namespace = ? and name = ?";

	print $sql . "\n";

	my $sth = $db->prepare($sql);

	my @args = map{ $$jobdef{$_} }@parms;
	push @args, ($$jobdef{namespace}, $$jobdef{name});

	print "Query arguments are:\n" . join("\n", @args) . "\n";
	return $sth->execute (@args);
}