# Copyright 2007 David Spadea
# All rights reserved.
#
# This code is release for use under the terms of the GNU General Public License, version 3.


package AdvancedScheduler::Database::db;
use DBI;
use base qw(DBI::db);

=head1 SetJobStatus


=cut

sub SetJobStatus
{
    my ($self, $jobname, $status) = @_;
            
    my $sql =<<SQL;
   
        select SetJobStatus(?, ?)
        
SQL

    my $sth = $self->prepare($sql);
    
    print sprintf ("Setting status %s for job %s\n", $status, $jobname);
        
    $sth->execute( $jobname, $status )
        or die ("SetJobStatus execute failed!");
    
    $sth->finish;
}


package AdvancedScheduler::Database::st;
use DBI;
use base (DBI::st);




package AdvancedScheduler::Database;
use strict;
use warnings;

use base qw(DBI);

sub connect
{
    my $class = shift;
    
    my $db = DBI->connect(sprintf ('dbi:Pg:host=%s;dbname=%s', $ENV{ADSHOST}, $ENV{ADSDB}),
                          $ENV{ADSUSER} ? $ENV{ADSUSER} : undef,
                          $ENV{ADSUSER} ? $ENV{ADSPASSWD} : $ENV{PGPASSWORD},
                          {RootClass => $class});
    
    return $db;
    
}



1;
