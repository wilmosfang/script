#!/bin/bash

printf '{"data":['

for i in `cat /proc/diskstats  | awk '{print $3}'`
do
    printf "{\"{#DISK}\":\"%s\"}," $i
done

echo -e '{"{#DISK}":"END"}]}'
