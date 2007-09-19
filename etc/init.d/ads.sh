#!/bin/sh
# Start/stop the Advanced Distributed Scheduler Agent daemon.
#
### BEGIN INIT INFO
# Provides:          agent.pl
# Required-Start:    $syslog $time $postgresql-8.2
# Required-Stop:     $syslog $time
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: Advanced Distributed Scheduler Daemon
# Description:       Agent daemon for running job streams for the
#                    Advanced Distributed Scheduler.
### END INIT INFO

. /etc/ads_setupenv.sh

test -f $ADSROOT/bin/agent.pl || exit 0

. /lib/lsb/init-functions

case "$1" in
start)	log_daemon_msg "Starting Advanced Distributed Scheduler Agent" "agent.pl"
        nohup start-stop-daemon --start --quiet --pidfile /var/run/adsagent.pid --startas $ADSROOT/bin/agent.pl 2>&1 &
        log_end_msg $?
	;;
stop)	log_daemon_msg "Stopping Advanced Distributed Scheduler Agent" "agent.pl"
        nohup start-stop-daemon --stop --quiet --pidfile /var/run/adsagent.pid 
        log_end_msg $?
        ;;
restart) log_daemon_msg "Restarting Advanced Distributed Scheduler Agent" "agent.pl" 
        start-stop-daemon --stop --retry 5 --quiet --pidfile /var/run/adsagent.pid
        nohup start-stop-daemon --start --quiet --pidfile /var/run/adsagent.pid --startas $ADSROOT/bin/agent.pl 2>&1 &
        log_end_msg $?
        ;;
*)	log_action_msg "Usage: /etc/init.d/ads.sh {start|stop|restart}"
        exit 2
        ;;
esac
exit 0
