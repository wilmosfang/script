#!/bin/bash
#
#used to filter some secinfo
#.dbct add a list of follow script
#s/patt/target/g


db_conv=/home/gituser/bin/.dbct

sed -f $db_conv -i  $1
