#!/usr/bin/env python

# Copyright 2007 David Spadea
# All rights reserved.
#
# This code is release for use under the terms of the GNU General Public License, version 3.


from sqlalchemy import *
from sqlalchemy.orm import *

session = create_session()
db = create_engine('postgres://ads:ads@localhost/ads')

db.echo = False
metadata = BoundMetaData(db)

job_table = Table('job', metadata, autoload = True)
machine_table = Table('machine', metadata, autoload = True)
runschedule_table = Table('runschedule', metadata, autoload = True)
#runrecord_table = Table('runrecord', metadata, autoload = True)

class ASObject(object):
    def commit(self):
        session.save(self)
        session.flush()
    
class Machine (ASObject):
    def __repr__(self):
            return "%s(%r,%r)" % (
                    self.__class__.__name__, self.name)
    
    def find( self, name ):
        query = session.query(Machine)
        return query.get_by(name = name)

class RunSchedule(ASObject):
    
    def find (self, machine):
        query = session.query(RunSchedule)
        return query.select(Machine = machine)

class Job(ASObject):
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
    
    def GetPending(self, Machine):
        return RunSchedule().find(Machine)

    def delete(self):
        session.delete(self)
        session.flush()
        


    
class RunRecord(ASObject):
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
mapper (RunSchedule, runschedule_table)
#mapper (RunRecord, runrecord_table)    

