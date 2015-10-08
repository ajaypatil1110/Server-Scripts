#!/bin/bash
#### Script will check logs after every 1hr and will send the alerts emails for the exceptions##########
last_one_hour=`date -d '60 minute ago'  +%d/%b/%Y:%H:`

DATE=`date +%Y-%m-%d`

#pages=`grep -i "$last_one_hour" /var/lib/tomcat7/logs/localhost_access_log.$DATE.txt | grep "HTTP/1.1\" 500" | grep 'checkout\|bag\|profile\|login\|register\|collection'|grep -v bags | sed 's/127.0.0.1 - - //' | sed 's/ -0500] "GET/] /' |  awk '{print $1 "   " $4}'`
pages=`grep -i "$last_one_hour" /var/lib/tomcat7/logs/localhost_access_log.$DATE.txt | grep "HTTP/1.1\" 500" | grep 'checkout\|bag' | grep -v bags | sed 's/127.0.0.1 - - //' | sed 's/ -0500] "GET/] /' |  awk '{print $1 "   " $4}'`

now=$(date +"%m_%d_%Y")

if [ -n "$pages" ]; then

        echo  "CheckoutException on APP01.pr ==>\n$pages" | mail -s "Code Orange $now : CheckoutException" "oncall-help@xyz.com, tech@xyz.com"

else

        echo "No error found"

fi
exit

