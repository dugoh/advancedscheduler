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
    my ($self, $jobid, $status) = @_;
            
    my $sql =<<SQL;
   
        update Job
        set Status = ? 
        where JobID = ?
        
SQL

    my $sth = $self->prepare($sql);
    
    print sprintf ("Setting status %s for jobid %d\n", $status, $jobid);
        
    $sth->execute($status, $jobid )
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
    
    my $db = DBI->connect('dbi:Pg:host=localhost;dbname=ads',
                          'ads',
                          'ads',
                          {RootClass => $class});
    
    return $db;
    
}



1;
