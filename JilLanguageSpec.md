# Introduction #

This document seeks to describe the most commonly used portions of the Job Information Language, or "JIL" for short.

# Details #

The general format of the JIL is a list of key-value pairs, delimited by colon (":"), usually with one key/value pair per line. JIL generally starts with a command, and is followed by details  describing changes to the job definition.

Note that it's possible to have multiple commands per line, and we probably want to support that, but it's not the normal use case. The exception is that sometimes job\_type: is on the same line as the insert/update\_job command.

## JIL commands ##

Jil commands generally start the input. They are key/value pairs where the key is the imperative portion, and  the value is the name of the job to be acted upon.

Valid commands are:

  * insert\_job  -- create a new job
  * update\_job  -- modify an existing job
  * delete\_job  -- delete an existing job

  * To do: add commands for adding machine definitions and globals. Are there others?


**Example command**

insert\_job: MY\_JOB\_NAME


## Job parameters ##

delete\_job takes no detail parameters, apart from the name of the job.

As for insert\_job and update\_job, the following attributes may be supplied in the JIL:

  * machine: the machine on which the job should be executed. If not specified, then the machine running the client will be assumed. This may also be set to 'all' if you want every machine to run a particular job.
  * command: the actual command to be executed
  * start\_mins: which minutes the job should be started every hour. This is a comma-separated list of minutes, e.g. 0,15,30,45
  * start\_times: actual times per day the job should be started. This is a comma-separated list of times, e.g. "5:15,15:30,23:59"
  * start\_days: comma-separated list of days on which the job should run, exclusive. These days are denoted using two-letter abbreviations: su,mo,tu,we,th,fr,sa
  * condition: rules that determine when a job should run based on the state of other jobs, e.g. "failure(JOB1) and (success(JOB2) or success(JOB3)) and notrunning(JOB4)"
  * alarm\_if\_fail: boolean (0/1) value determining whether an alarm should be sent upon a job failure event.
  * date\_conditions: 0/1 -- determines whether time/day constraints will be taken into consideration when determining when to kick off jobs. If 0, start\_times, start\_mins, and start\_days will be ignored, and job control will be based on the condition field only.
  * std\_in\_file: file that will be redirected into the command as STDIN. Specify full path. Autosys does not provide this utility, but it should be trivial to add. (ADS Extension)
  * std\_out\_file: file that will receive the job's STDOUT. Specify full path.
  * std\_err\_file: file that will receive the job's STDERR. Specify full path.
  * profile: file that will be sourced by the shell prior to kicking off the job.
  * run\_window: A range of hours, such as "7:00 - 10:00", which restricts the possible start times of the job. If you specify "start\_mins: 15,30", then the job will run on 7:15, 7:30, 8:15 ... 10:30, and will then wait until the next available 7:15 (taking day restrictions into account).

TO DO: Add File Watcher and Box Job information


