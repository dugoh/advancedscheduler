#!/usr/bin/env python

# Copyright 2007 David Spadea
# All rights reserved.
#
# This code is release for use under the terms of the GNU General Public License, version 3.


import sys
import re


sys.path.append('../lib')

from Database import *

jil = sys.stdin.readlines()

job = None

for line in jil:
    parameter, value = line.split(':', 1)
    
    parameter = parameter.strip()
    value = value.strip()
    
    if re.compile('#').search(parameter,1):
        pass
    
    elif 'update_job' == parameter:
        if job != None:
            job.commit()
            
        job = Job().find(value)
        
        if job == None:
            print "Couldn't find job " + value + "\n"
            exit (-1)
            
        if ( job != None ):
            print "Updating job " + job.name + "\n"
        else:
            print "Update job: Couldn't find job with name " + value + "\n"
        
    elif 'insert_job' == parameter:
        if job != None:
            job.commit()
        
        print "Inserting job " + value + "\n"
        job = Job()
        job.name = value
        
    elif 'delete_job' == parameter:
        print "Deleting job " + value + "\n"
        job = Job().find(value)
        job.delete()
        job = None
    
    elif job != None and parameter in ( 'std_in_file', 'std_err_file', 'std_out_file',
                                        'machine', 'start_mins', 'start_days', 'command'
                      ):
            print "Setting " + parameter + " to '" + value + "'\n"
            setattr(job, parameter, value)

            
if (job != None):
    job.commit()

print "Complete.\n"
