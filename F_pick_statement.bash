#!/bin/bash
#
#used to get the slowsql by patten
#usage: x <patten>


log_file=/path/to/mysql/slow.log

sudo grep -C 6  --color $1 $log_file
