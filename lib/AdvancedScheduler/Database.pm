# Copyright 2007 David Spadea
# All rights reserved.
#
# This code is release for use under the terms of the GNU General Public License, version 3.


package AdvancedScheduler::Database::db;
use DBI;
use base qw(DBI::db);




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
