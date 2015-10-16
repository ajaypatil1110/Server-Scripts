#!/bin/bash 
### Script to check tomcat localhost_access_log.xxx log file for Exceptions(eg./checkout,/bag) and send email alerts.

### Required date and time formats
last_one_hour=`date -d '60 minute ago'  +%d/%b/%Y:%H:`

DATE=`date +%Y-%m-%d`

now=`date +"%m_%d_%Y"`

### Convert hostname into Upper case
host=`hostname -s | tr 'a-z' 'A-Z'`

### Add Exceptions here
array="/checkout /bag /register"

for i in $array
do
	### grep the exception string from log file
        pages=`grep -i "$last_one_hour" /var/lib/tomcat7/logs/localhost_access_log.$DATE.txt | grep "HTTP/1.1\" 500" | grep $i | grep -v bags | cut -d[ -f2 | awk '{print $1 "     " $4}'`

        echo "$pages"

        name=`echo $i | awk -F/ '{print $2}' | sed 's/.*/\u&/')`

        exc='Exception'

                if [ -n "$pages" ]; then
                        echo  "$name exception on $host ==>\n$pages" | mail -s "Code Orange $now : $name$exc " "abc@xyz.com"
                else
                        echo "No error found"
                fi
done

exit
