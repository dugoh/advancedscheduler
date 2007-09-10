#!/usr/bin/perl


# Copyright 2007 David Spadea
# All rights reserved.
#
# This code is release for use under the terms of the GNU General Public License, version 3.


use lib qw(../lib);

use strict;
use warnings;

use AdvancedScheduler::Database;

use Getopt::Long;
use Data::Dumper;

my %opts;

GetOptions( 'E=s' => \$opts{Event},
            'event=s' => \$opts{Event},
            'J=s' => \$opts{Job},
            'job=s' => \$opts{Job},
            'P=i' => \$opts{Priority},
            'priority=i' => \$opts{Priority}
          );

#print "Got options: " . Dumper(\%opts);

my $db = AdvancedScheduler::Database->connect_cached;

my %events = (
  forcestartjob => \&forcestartjob
);

my $event = $opts{Event};

$event =~ s/_//g;
$event = lc $event;

if ($events{$event})
{
    exit ( $events{$event}->($db, \%opts) );
}

warn ("No such event $opts{Event}\n");

exit 99;

sub forcestartjob
{
    my ($db, $opts) = @_;
    
    $db->begin_work;

    my $sql =<<SQL;

    Update Job
    set status = 'AC'
    where job.name = ?;
    
SQL

    my $sth = $db->prepare($sql);
    $sth->execute($$opts{Job} ) or ($db->rollback and return 1);
    
    $sql =<<SQL;
    
    delete
    from RunSchedule
    where RunSchedule.JobID =
        ( select JobID
          from Job
          where job.name = ?
        );
SQL

    $sth = $db->prepare($sql);
    $sth->execute($$opts{Job} ) or ($db->rollback and return 1);
    
    $sql =<<SQL;

    insert into RunSchedule (
        machine,
        jobid,
        next_run,
        condition,
        assigned_agent
    )
    select machine,
           jobid,
           CURRENT_TIMESTAMP,
           condition,
           NULL
    from Job
    where job.name = ?;
    
SQL

    $sth = $db->prepare($sql);
    $sth->execute($$opts{Job} ) or ($db->rollback and return 1);
    

    
    $db->commit;
    
    return 0;

}