#!/bin/bash


#need 3 args
#$1 : report file
#$2 : items number
#$3 : slow query log file

echo "#[Base info]###############"
grep -E '# Files:' $1 | sed 's/Files:/Log Files:/'
head $1 | grep '# Time range:'
grep '# Overall:' $1 | cut -f 1,2 -d ','
echo -e "\n\n\n"
i=1



echo "#[Analyze info]############"
while [ $i -le $2 ]
do
	echo "#Query $i###############"
	grep "#    $i " $1  | awk '{printf("time percent:%s\ntotal response time:%s\nCalls:%s\nresponse per call:%s\nitem:%s %s\n",$5,$4,$6,$7,$9,$10)}'
	echo "#Generate by follow operation"
        #grep 'SHOW CREATE TABLE' $1 | sed -n "${i}p" | cut -f 4 -d '`' |xargs -I {} grep {} $3 | head -n 3 	
        grep '^#    SHOW CREATE TABLE' $1 | sed -n "${i}p" | cut -f 4 -d '`' |xargs -I {} grep {} $3 | tail -n 3 	
	echo "#use follow commands to dig table"
	grep -E '^#    SHOW TABLE STATUS|^#    SHOW CREATE TABLE' $1 | sed -n "$(($i*2-1)),$(($i*2))p" 
	grep '^#    SHOW CREATE TABLE' $1 | sed -n "${i}p" | sed "s/SHOW CREATE TABLE/SHOW INDEX FROM/" 
	i=$(($i+1))
	echo "#table info area#######"
	echo "Please refer to attachment"
	echo "#Analyze area##########"
	echo -e "\n\n\n"
	
done 
