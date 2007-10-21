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
use Time::HiRes qw(usleep);
use Data::Dumper;

$| = 1;

print "**** ADVANCED DISTRIBUTED SCHEDULER ****\n\n";

my $maxExecutors = 5;

my $agentid = join("-", hostname(), $PID, time);
print "Starting AgentID $agentid\n";
print "Start time is: " . scalar(localtime) . "\n";
print "Max executors: $maxExecutors\n\n";

use YAML qw(freeze thaw);

our $EXIT_FLAG : shared;
our $JobQueue : shared;
our $JobResults : shared;
our $StatQueue : shared;

our @Executors;

$JobQueue = new Thread::Queue;
$JobResults = new Thread::Queue;
$StatQueue = new Thread::Queue;

$EXIT_FLAG = 0;

use AdvancedScheduler::Database;

sub HandleExit
{
    lock ($EXIT_FLAG);

    $EXIT_FLAG = 1;
}

$SIG{TERM} = \&HandleExit;

my $manager = threads->create(\&WorkManager);    
#my $worker = threads->create(\&ExecWork);
my $statusmanager = threads->create(\&StatusManager);

# Start Executors

foreach (1..$maxExecutors)
{
    print "Starting Executor thread...\n";
    push @Executors, threads->create(\&ExecWork);
}


while (1)
{
    last if $EXIT_FLAG;
    sleep 3;
}

print "MainLoop: Got EXIT_FLAG. Waiting for threads to exit.\n";

$manager->join;
#$worker->join;
$statusmanager->join;

foreach (@Executors)
{
    print "Waiting for Executor to exit..\n";
    $_->join;
}

print "MainLoop: Threads exited. Quitting.\n";
exit 0;

=head1 WorkManager

Reads pending events from the database and adds them to the work queue.

This does not exit until the $EXIT_FLAG is set by a SIGTERM.

=cut

sub WorkManager
{
    my $db = AdvancedScheduler::Database->connect
        or die ("Work Manager was unable to connect to the database!");
        
    my $sql =<<SQL;
    
    select *
    from PendingJobs
    where (Machine = ? or Machine = 'all')
      and (assigned_agent is null
           or assigned_agent != ?)

SQL

    
    my $sth = $db->prepare($sql);
    
    while (! $EXIT_FLAG)
    {
        $sth->execute(hostname(), $agentid);
        
        while (my $jobdef = $sth->fetchrow_hashref)
        {
            {
                lock ($JobQueue);
                my $jobid = $$jobdef{name};
                
                unless ($$jobdef{machine} eq 'all')
                {
                    my $sql = 'update runschedule set Assigned_Agent = ? where jobid = ?';
                    my $update = $db->prepare($sql);
                    $update->execute($agentid, $$jobdef{jobid});
                }
                
                print scalar localtime(time) . " Enqueuing:" . $$jobdef{name} . "\n";
                $jobdef = freeze($jobdef);
                $JobQueue->enqueue($jobdef);
                
                SetJobStatus($jobid, 'ST');
            }
        }
        
        $sth->finish;
        
        sleep 2;
    }
    
    print "WorkManager: Got EXIT_FLAG. Quitting.\n";
    return 0;
}

=head1 ExecWork

Read the queue and run all scheduled commands

Early implementation will just run them in serial as noted in the queue. This
will eventually need to be some sordft of parallel implementation. 

=cut

sub ExecWork
{
    my $jobdef;
    
   # my $db = AdvancedScheduler::Database->connect
    #    or die ("ExecWork was unable to connect to the database!");
        
    while ( ! $EXIT_FLAG )
    {
        while ( $JobQueue->pending)
        {
            {
                lock($JobQueue);
                $jobdef = $JobQueue->dequeue_nb;
            }
            
            if ($jobdef)
            {
                $jobdef = thaw($jobdef);
                print scalar localtime(time) . " Will execute: " . $$jobdef{name} . "\n";
                
                SetJobStatus($$jobdef{name}, 'RU');
                
                my $cmd = &CreateCmd($jobdef);
                
                print $$jobdef{name} . ": Command is:\n$cmd\n";
                system($cmd);
                
                my $rc = ($? >> 8);
                print "Return status = $rc\n";
                
                SetJobStatus($$jobdef{name}, ($rc ? 'FA' : 'SU'));
            }
        }
        
        sleep 1;
    }
    
    print "ExecWork: Got EXIT_FLAG. Quitting.\n";
    return 0;
}

sub CreateCmd
{
    my $jobdef = shift;
    
    my ($in, $out, $err) =
        ($$jobdef{std_in_file}, $$jobdef{std_out_file}, $$jobdef{std_err_file});
    
    $in ||= '/dev/null' unless ($in);
    $out ||= $ENV{ADSJOBLOG} . "/" . $$jobdef{name} . '.$(date +"%Y%m%d").log';

    my $cmd = $$jobdef{command};
    $cmd .= " < $in ";
    $cmd .= " >>$out ";
    $cmd .= $err ? " 2>>$err " : ' 2>&1 ';
    
    # Handle owner
    $cmd =  "sudo -u $$jobdef{owner} bash -c '$cmd'";
    
    # Handle chroot
    $cmd = "chroot $$jobdef{chroot} " . $cmd;
    
    return $cmd;
}

sub SetJobStatus
{
    my ($jobname, $status) = @_;

    {
        lock($StatQueue);
        $StatQueue->enqueue( freeze ({ name => $jobname, status => $status} ));
    }
    
    return 1; 
}



# If this queue gets backed up for some reason, it could cause some apparent
# distortion in the event times. If that happens, we'll need to capture
# the enqueue time in SetJobStatus and use that as the event time,
# rather than the time at processing.
# Except for periods of extremely high load, the status should be updated in the
# database almost instantaneously, so it's better to let the database
# set the times on the record rather than using the host clock to get the enqueue time.

sub StatusManager
{
    my ($stat);
 
    my $db = AdvancedScheduler::Database->connect;
    
    while (! $EXIT_FLAG)
    {
        while ( $StatQueue->pending )
        {
            
            {
                lock($StatQueue);
                $stat = $StatQueue->dequeue_nb;
            }
            
            if ($stat)
            {
                $stat = thaw($stat);
            
                $db->SetJobStatus($$stat{name}, $$stat{status});
            }
        }
        
        sleep 1;
        
    }
    
    print "StatusManager: Got EXIT_FLAG. Quitting.\n";
    return 0;
}
