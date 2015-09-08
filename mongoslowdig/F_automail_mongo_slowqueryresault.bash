#!/bin/bash


/bin/mail -r yyghdfz@163.com  -s 'MongoDB Slow query log analyze' -a $1/*.txt   fangzheng@boohee.com  < $1/*.txt 
