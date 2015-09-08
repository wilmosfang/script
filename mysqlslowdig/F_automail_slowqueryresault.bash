#!/bin/bash

#require one arg for tmpdir

/bin/mail -r wilmos@def.com  -s 'Slow query log analyze' -a $1/y.table.details  -a $1/x.table.details -a $1/y.slowlog.report -a $1/x.slowlog.report  wilmos@abc.com  < $1/summary 
