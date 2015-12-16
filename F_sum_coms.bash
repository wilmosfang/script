#!/bin/bash
#
#used to generate the commands summary
#

grep '^\[.*\@'  $1    | sed 's/\][#$]/?~/' |awk  -F'\?\~'  '{print $2}' | sed  's/^\#//;s/^\$//;/^\s*$/d;s/^\s*//;s/\s*$//;s/^/* **`/;s/$/`**/'
