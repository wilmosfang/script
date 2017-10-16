#!/bin/bash

printf '{"data":['

for i in `netstat -tnl| grep  LISTEN|awk '{print $4}'| awk -F ':' '{print $NF}' | sort -run`
do
    printf "{\"{#OPENPORT}\":\"%d\"}," $i
done

echo -e '{"{#OPENPORT}":"END"}]}'
