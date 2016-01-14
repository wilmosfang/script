#!/bin/bash


##
#require qshell
#$1 is phone number 
#$2 is messages with utf-8
#




###help info 
help_info()
{
cat <<EOF
usage:$0 <'phone_numbers'>  <'message'> 
 
Example:$0  '18045678901,18645678902'   '你好'

output:
	will get the jason response something like

{
  "Rets": [
    {
      "Rspcode": 0,
      "Msg_Id": " 114445276129660989",
      "Mobile": "18045678901"
    },
    {
      "Rspcode": 0,
      "Msg_Id": " 114445276129660991",
      "Mobile": "18645678902"
    }
  ]
}


More: <'phone_numbers'>  <'message'>  must be specified and only two args
	it need two args and only two args 

EOF
}

##simple check for input args

if [ "$#" -ne "2" ]
then
        help_info
        exit 1
fi 


##
##need to be specified in CLI

mobile="$1"
content="$2"


##tools path
##need to be configed manually
QTOOLS=./qtools
CURL=/usr/bin/curl


##config area
##need to be configed manually
account='xxxx'
password='xxxxxxxx'

##auto config
timestamps=`date +%s`
timestamps=$timestamps'000'
#url='http://139.129.128.71:8086/msgHttp/json/mt'
url='http://newip:newport/msgHttp/json/mt'

##generate args for curl
url_account=`$QTOOLS urlencode "$account"`
url_pass_temp=`echo -n "$password$mobile$timestamps"|md5sum | awk '{print $1}' `
url_pass=`$QTOOLS urlencode "$url_pass_temp"`
url_time=`$QTOOLS urlencode "$timestamps"`
url_mobile=`$QTOOLS urlencode "$mobile"`
url_content=`$QTOOLS urlencode "$content"`

#debug area
#echo $url_account
#echo $url_pass
#echo $url_mobile
#echo $url_content
#echo $url_time
#echo $url_pass_temp
#echo "$url?account=$url_account&password=$url_pass&timestamps=$url_time"
#echo "$url"
#echo "account=$url_account&password=$url_pass&mobile=$url_mobile&content=$url_content&timestamps=$url_time"

# action area
#$CURL -X POST  "$url?account=$url_account&password=$url_pass&mobile=$url_mobile&content=$url_content&timestamps=$url_time"
$CURL -X POST  "$url" -d "account=$url_account&password=$url_pass&mobile=$url_mobile&content=$url_content&timestamps=$url_time"

