#!/usr/bin/env python

from sqlalchemy import *
from sqlalchemy.orm import *

session = create_session()
db = create_engine('postgres://ads:ads@localhost/ads')

db.echo = False
metadata = BoundMetaData(db)

job_table = Table('job', metadata, autoload = True)
machine_table = Table('machine', metadata, autoload = True)
#runrecord_table = Table('runrecord', metadata, autoload = True)

def commit_changes(obj):
    session.save(obj)
    session.flush()

def delete_job(obj):
    session.delete(obj)
    session.flush()
    
class Machine (object):
    def __repr__(self):
            return "%s(%r,%r)" % (
                    self.__class__.__name__, self.name)
    
    def find( self, name ):
        query = session.query(Machine)
        return query.get_by(name = name)


class Job(object):
    def __repr__(self):
            return "%s(%r,%r)" % (
                      self.__class__.__name__
                    , self.name
                    , self.machine
                    , self.status
                    , self.start_days
                    , self.start_mins
                    , self.command
                    , self.std_out_file
                    , self.std_in_file
                    , self.std_err_file
                )

    def find( self, name ):
        query = session.query(Job)
        return query.get_by(name = name)


class RunRecord(object):
    def __repr__(self):
            return "%s(%r,%r)" % (
                      self.__class__.__name__
                    , self.job
                    , self.status
                    , self.start_time 
                    , self.end_time
                )

mapper (Job, job_table)
mapper(Machine, machine_table)
#mapper (RunRecord, runrecord_table)    

