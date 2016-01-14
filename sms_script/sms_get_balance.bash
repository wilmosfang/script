#!/bin/bash
#require qshell
#


##tools path config
QTOOLS=./qtools
CURL=/usr/bin/curl

##config area
account='xxxxxx'
password='xxxxxxx'

##auto config
timestamps=`date +%s`
timestamps=$timestamps'000'
#url='http://139.129.128.71:8086/msgHttp/json/balance'
url='http://newip:newport/msgHttp/json/balance'

##generate args for curl
url_account=`$QTOOLS urlencode $account`
url_pass_temp=`echo -n $password$timestamps|md5sum | awk '{print $1}' `
url_pass=`$QTOOLS urlencode $url_pass_temp`
url_time=`$QTOOLS urlencode $timestamps`

#debug area
#echo $url_account
#echo $url_pass
#echo $url_pass_temp
#echo $url_time
#echo $timestamps
#echo "$url?account=$url_account&password=$url_pass&timestamps=$url_time"

##to get the data 
#$CURL -X POST  "$url?account=$url_account&password=$url_pass&timestamps=$url_time"
$CURL -X POST  "$url" -d "account=$url_account&password=$url_pass&timestamps=$url_time"
