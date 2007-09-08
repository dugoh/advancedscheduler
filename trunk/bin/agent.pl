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
    
    &SetJobStatus;
    
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

SQL

    
    my $sth = $db->prepare($sql);
    $sth->execute(hostname());
    
    while (my $jobdef = $sth->fetchrow_hashref)
    {
        {
            lock ($JobQueue);
            my $jobid = $$jobdef{jobid};
            
            $jobdef = freeze($jobdef);
            print scalar localtime(time) . " Enqueuing:\n" . $jobdef . "\n\n";
            $JobQueue->enqueue($jobdef);
            
            &SetJobStatus($jobid, 'ST');
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
    while ( my $jobdef = $JobQueue->dequeue_nb )
    {
        $jobdef = thaw($jobdef);
        print scalar localtime(time) . " Will execute: " . Dumper($jobdef);
        
        &SetJobStatus($$jobdef{jobid}, 'RU');
        system($$jobdef{command});
        my $rc = ($? >> 8);
        print "Return status = $rc\n";
        
        &SetJobStatus($$jobdef{jobid}, ($rc ? 'FA' : 'SU'));
    }
}

=head1 SetJobStatus


=cut

sub SetJobStatus
{
    my ($jobid, $status) = @_;
    
    my $db = AdvancedScheduler::Database->connect_cached
        or die ("Work Manager was unable to connect to the database!");
        
    my $sql =<<SQL;
   
        update Job
        set Status = ? 
        where JobID = ?
        
SQL

    my $sth = $db->prepare($sql);
    
    print sprintf ("Setting status %s for jobid %d\n", $status, $jobid);
        
    $sth->execute($status, $jobid )
        or die ("SetJobStatus execute failed!");
    
    $sth->finish;
    
}

