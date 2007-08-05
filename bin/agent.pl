#!/usr/bin/perl -w


# Copyright 2007 David Spadea
# All rights reserved.
#
# This code is release for use under the terms of the GNU General Public License, version 3.



use strict;
use warnings;
use lib qw(../lib);

use AdvancedScheduler::Database;

use threads;
use Thread::Queue;

sub HandleExit
{
    $EXIT_FLAG->up;
}

=head1 WorkManager

Reads pending events from the database and adds them to the work queue.

This does not exit until the $EXIT_FLAG semaphore is set by a SIGTERM.

=cut

sub WorkManager
{
    my $db = AdvancedScheduler::Database->connect
        or die ("Work Manager was unable to connect to the database!");
        
    
    
}
