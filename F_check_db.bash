#!/bin/bash
#
#used to get the query time from slow log
#usage: x    #and then inpurt the password
#

log_file=/path/to/mysql/slow.log

sudo awk /Query_time/'{print $3}' $log_file
