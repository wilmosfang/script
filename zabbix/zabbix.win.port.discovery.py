#for windows openport discovery
#python 2.7

import os
import re

command ='netstat -ant|find "TCP"'
res=os.popen(command)
port_set=set()

for line in res:
    port_set.add(re.split(':',re.split('\s+',line)[2])[-1])

print '{"data":[',
for port in port_set:
    print "{\"{#OPENPORT}\":\""+ port + "\"},",
print  '{"{#OPENPORT}":"END"}]}'
