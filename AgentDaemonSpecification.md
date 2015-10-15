# Introduction #

Need an agent daemon to run the jobs on the specified machine. Daemon should be written in Python, and should use the Job class to maintain the job states. This agent will run on all configured hosts. It is not a central controller.

# Details #


This daemon should query a configurable database for a list of pending
jobs. The logic to determine the list should reside in stored procedures.
The daemon should be as small as possible, while achieving the following goals:

  * Set appropriate job status:
    * 'ST' (starting) -- Job session setup, before job is actually started
    * 'RU' (running) -- Job has actually started running
    * 'TE' (terminated) -- Job was killed via ADS control command
    * 'FA' (failed) -- Job exited with non-zero status
    * 'SU' (success) -- Job exited with zero status

  * Run all pending jobs in parallel. Logic for limiting number of concurrent jobs based on machine load is a nice-to-have early on, but will become mandatory as the project matures.

  * Listen on a control mechanism (dbus?) for control commands
    * Agent shutdown
    * Terminate job (SIGTERM)
    * Kill job (SIGKILL)

  * Should periodically (every minute?) set its status in a table keyed on hostname. This will serve as a monitoring mechanism should the daemon die. Should agent receive a shutdown command, it should write a "shutdown" status to the table before quitting.


