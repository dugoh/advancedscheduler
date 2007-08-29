#!/usr/bin/perl -w


# Copyright 2007 David Spadea
# All rights reserved.
#
# This code is release for use under the terms of the GNU General Public License, version 3.



use strict;
use warnings;
use lib qw(../lib);

use threads;
use Thread::Queue;

use YAML qw(freeze thaw);

our $EXIT_FLAG : shared;
our $JobQueue : shared;

$JobQueue = new Thread::Queue;

$EXIT_FLAG = 0;

use AdvancedScheduler::Database;

$SIG{CHLD} = \&HandleExit;

&WorkManager;

sub HandleExit
{
    lock ($EXIT_FLAG);

    $EXIT_FLAG = 1;
}

=head1 WorkManager

Reads pending events from the database and adds them to the work queue.

This does not exit until the $EXIT_FLAG is set by a SIGTERM.

=cut

sub WorkManager
{
    my $db = AdvancedScheduler::Database->connect
        or die ("Work Manager was unable to connect to the database!");
        
    my $sql = "select * from RunSchedule where Machine = ?" ;
    
    while (! $EXIT_FLAG )
    {
        my $sth = $db->prepare($sql);
        $sth->execute('titan');
        
        while (my $jobdef = $sth->fetchrow_hashref)
        {
            {
                lock ($JobQueue);
                $jobdef = freeze($jobdef);
                print "Enqueuing:\n" . $jobdef . "\n\n";
                $JobQueue->enqueue($jobdef);
            }
        }
        
        sleep 5;
    }
    
}
