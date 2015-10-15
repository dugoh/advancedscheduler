# Introduction #

Autorep is a command-line utility used primarily for extracting job definitions and run record information from the database.


# Details #

  * Default behavior is to report current status for a list of jobs matching a pattern. Patterns will use SQL-style '%' for wildcards (E.g. %job would match anything ending in 'job'. My%job% would match My\_New\_job\_1, My\_job, Myjob, etc. )
  * Output JIL for a list of jobs matching the same-style pattern. This is selected via the '-q' switch.
  * Job names are specified with the -J parameter.

Sample command lines:

  * report the status for all jobs matching the pattern.
> autorep -J My%Job

  * output JIL for all jobs matching a pattern
> autorep -q -J My\_Job%xyz


You can also use the --format parameter to specify a report output format. The default is the normal Autosys-style autorep output. The other two, which are more friendly to statistics collecting scripts and other parsers, are XML and YAML.




