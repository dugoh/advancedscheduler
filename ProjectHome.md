This project aims to be an Autosys compatible framework for control of enterprise job streams. Jobs may be scheduled based on time, as well as on the status of other jobs. This allows for fine-grained control over job streams -- especially compared to cron and other simple time-based schedulers.

While the short-term goal is to be Autosys-compatible, the ultimate goal is to provide innovative facilities that Autosys does not, and to remove several of the artificial constraints placed on users by the AutoSys product.

It will implement an similar user interface, when feasible, in order to avoid a high learning curve and excessive changes to existing monitoring and reporting infrastructure.

The blog, linked at right, is a good source of information on what work is being done, work planned for the near future, and general project direction.



## Highlights ##

  * Accepts most existing Autosys JIL
  * Autosys compatible interfaces make migration easier
  * Developer- and integrator-friendly.
    * Easy-to-understand database schema and command-line utilities.
  * Completely implemented using F/OSS technology, such as PERL and Postgres, so ADS is easily maintained, low cost, and highly customizable.
  * Clients are kept as simple as possible, so re-implementing or porting to a new platform should be fairly straight-forward. Most logic is implemented in Postgres, so it works on any platform that supports Postgres.

## Features currently implemented ##

  * Conditional scheduling logic
  * No limits on job name length
  * Reads and persists many common JIL fields to Postgres, even if they're not yet implemented.
  * Scheduling based on start\_mins and start\_times, start\_days, and job conditions.
  * insert\_job, update\_job, delete\_job commands
  * Many common features of sendevent, autorep, and jil utilities implemented.
  * std\_out\_file, std\_err\_file, and std\_in\_file. "std\_in\_file" is an ADS extension of JIL.
  * Ability to switch ADS databases via environment variables
  * Agent runs configurable number of job executor threads. This allows you to throttle the number of concurrent jobs running on each machine.
  * Job 'namespaces' are compatible with Autosys idea of 'Instance', except that it gives a few other advantages:
    * No more scoping by prepending the system to the job name.
      * Large installations with multiple streams often name their jobs following a convention like `GROUP-PRODUCT-real-job-name`. Now you can set your namespace to `GROUP-PRODUCT` and simply use `real-job-name` as your job name.
    * If you're really stuck on the idea of an Autosys "instance", just set your namespace to the autosys instance name for compatibility. This means you can combine multiple autosys instances on one database.

## Planned Features ##

  * Will allow distributed job management using multiple master database servers for better scalability.
  * Autorep output will support parser-friendly formats, like YAML and XML, in addition to the familiar autorep format.