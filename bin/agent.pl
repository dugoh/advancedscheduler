#!/usr/bin/perl -w


# Copyright 2007 David Spadea
# All rights reserved.
#
# This code is release for use under the terms of the GNU General Public License, version 3.



use strict;
use warnings;
use lib ("$ENV{ADSROOT}/lib");

use threads;
use Thread::Queue;

use English;
use Sys::Hostname;

use Data::Dumper;

my $agentid = join("-", hostname(), $PID, time);
print "Starting AgentID $agentid\n";

use YAML qw(freeze thaw);

our $EXIT_FLAG : shared;
our $JobQueue : shared;
our $JobResults : shared;

$JobQueue = new Thread::Queue;
$JobResults = new Thread::Queue;

$EXIT_FLAG = 0;

use AdvancedScheduler::Database;

sub HandleExit
{
    lock ($EXIT_FLAG);

    $EXIT_FLAG = 1;
}

$SIG{TERM} = \&HandleExit;

# Early implementation has this loop here, but eventually
# this loop should be moved inside of each sub, and they
# should run in different threads. I wasn't sure about
# how SIGCHLD/fork/exec and system() interact with threads, so
# I'm chickening out of that for the time being.

while ( ! $EXIT_FLAG )
{
    &WorkManager;
    
    &ExecWork;
    
    sleep 2;
}

=head1 WorkManager

Reads pending events from the database and adds them to the work queue.

This does not exit until the $EXIT_FLAG is set by a SIGTERM.

=cut

sub WorkManager
{
    my $db = AdvancedScheduler::Database->connect_cached
        or die ("Work Manager was unable to connect to the database!");
        
    my $sql =<<SQL;
    
    select *
    from PendingJobs
    where Machine = ?
      and (assigned_agent is null
           or assigned_agent != ?)

SQL

    
    my $sth = $db->prepare($sql);
    $sth->execute(hostname(), $agentid);
    
    while (my $jobdef = $sth->fetchrow_hashref)
    {
        {
            lock ($JobQueue);
            my $jobid = $$jobdef{name};
            
            $jobdef = freeze($jobdef);
            print scalar localtime(time) . " Enqueuing:\n" . $jobdef . "\n\n";
            $JobQueue->enqueue($jobdef);
            
            $db->SetJobStatus($jobid, 'ST');
        }
    }
    
    $sth->finish;
    
    
}

=head1 ExecWork

Read the queue and run all scheduled commands

Early implementation will just run them in serial as noted in the queue. This
will eventually need to be some sordft of parallel implementation. 

=cut

sub ExecWork
{
    my $db = AdvancedScheduler::Database->connect_cached
        or die ("ExecWork was unable to connect to the database!");
        
    while ( my $jobdef = $JobQueue->dequeue_nb )
    {
        $jobdef = thaw($jobdef);
        print scalar localtime(time) . " Will execute: " . Dumper($jobdef);
        
        $db->SetJobStatus($$jobdef{name}, 'RU');
        system($$jobdef{command});
        my $rc = ($? >> 8);
        print "Return status = $rc\n";
        
        $db->SetJobStatus($$jobdef{name}, ($rc ? 'FA' : 'SU'));
    }
}



