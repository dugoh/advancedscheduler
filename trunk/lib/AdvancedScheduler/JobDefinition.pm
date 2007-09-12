package AdvancedScheduler::Container;

sub AUTOLOAD
{

	my $self = shift;

	my $field = lc $AUTOLOAD;

	$field =~ s/.*://; # strip package information

	return defined $$self{$field} ? $$self{$field} : undef; # don't autovivify
}


package AdvancedScheduler::JobDefinition;

use base qw(AdvancedScheduler::Container);

sub Parse
{
	my ($class, $jil) = @_;
	my %def;

	$jil =~ s/job_type/\njob_type/ig; # autorep puts job_type on the same line as insert_job.

	my @attributes = split ('\n', $jil);

	map {
		my ($key, $value) = split (/:/, $_, 2);

		if ($value)
		{
			chomp $value;
			
			$key =~ s/^\s+//;
			$key =~ s/\s+$//;
			$value =~ s/^\s+//;
			$value =~ s/\s+$//;

			my %rename = (
				'#owner' => 'owner',
				'insert_job|update_job|delete_job' => 'name',
			);

			map {
				if ( $key =~ /^insert_job|update_job|delete_job/)
				{
					$def{ADSCOMMAND} = $key;
					
				}

				$key =~ s/$_/$rename{$_}/;

			} keys %rename;

			$def{$key} = $value;
		}

	} @attributes;

	return bless \%def, $class;
}

1;
