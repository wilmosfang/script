#!/bin/bash
#
#used to filter some patten from a doc
#filter_list list all the patten
#

for i in `cat ~/bin/.filter_list`
do 
egrep --color  "$i"  $1 &&  echo "[$i]"
done

