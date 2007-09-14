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

my $manager = threads->create(\&WorkManager);    
my $worker = threads->create(\&ExecWork);

while (1)
{
    last if $EXIT_FLAG;
    sleep 1;
}

$manager->join;
$worker->join;

print "MainLoop: Got EXIT_FLAG. Quitting.\n";
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
    where Machine = ?
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
                
                print scalar localtime(time) . " Enqueuing:" . $$jobdef{name} . "\n";
                $jobdef = freeze($jobdef);
                $JobQueue->enqueue($jobdef);
                
                $db->SetJobStatus($jobid, 'ST');
            }
        }
        
        $sth->finish;
        
        sleep 2; # Only query DB every two seconds.
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
    
    my $db = AdvancedScheduler::Database->connect
        or die ("ExecWork was unable to connect to the database!");
        
    while ( ! $EXIT_FLAG )
    {
        {
            lock($JobQueue);
            $jobdef = $JobQueue->dequeue_nb;
        }
        
        if ($jobdef)
        {
            $jobdef = thaw($jobdef);
            print scalar localtime(time) . " Will execute: " . $$jobdef{name} . "\n";
            
            $db->SetJobStatus($$jobdef{name}, 'RU');
            
            my $cmd = &CreateCmd($jobdef);
            
            print $$jobdef{name} . ": Command is:\n$cmd\n";
            system($cmd);
            
            my $rc = ($? >> 8);
            print "Return status = $rc\n";
            
            $db->SetJobStatus($$jobdef{name}, ($rc ? 'FA' : 'SU'));
        }
        
        sleep 1;
    }
    
    print "WorkManager: Got EXIT_FLAG. Quitting.\n";
    return 0;
}

sub CreateCmd
{
    my $jobdef = shift;
    
    my ($in, $out, $err) =
        ($$jobdef{std_in_file}, $$jobdef{std_out_file}, $$jobdef{std_err_file});
    
    $in ||= '/dev/null' unless ($in);
    $out ||= "$ENV{ADSJOBLOG}/$$jobdef{name}.log";
    $err ||= $out;

    my $cmd = $$jobdef{command};
    $cmd .= " < $in";
    $cmd .= " >>$out";
    $cmd .= " 2>>$err";
    
    return $cmd;
}


