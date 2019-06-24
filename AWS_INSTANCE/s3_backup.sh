#!/bin/bash -l

#  Load S3 Variables with '-l' flag above, variables are stored in ~/.profile

#-----------------------------------------------------------------------
#
#  S 3 _ B A C K U P . S H
#
#  Backup to S3 key config files and folders
#
#-----------------------------------------------------------------------

#  Determine if s3cmd is installed
if ! which s3cmd > /dev/null;
then
   echo "Unable to find s3cmd command"
   exit 1
fi

#  Set Variables
SERVER=$(hostname -s)
DAY=$(date +%A)
ENVIRONMENT=$(cat /etc/xyz/server_environment)
SERVER_LIST=/etc/xyz/s3_backup.txt
FOLDERS=$(cat "$SERVER_LIST" | grep "$SERVER:" | cut -f2 -d":")

#  Get list of folders into array
arrayname=($(echo "$FOLDERS"))

#  Loop and backup each folder
if [ ${#arrayname[@]} > 0 ]; then
   for m in "${arrayname[@]}"
   do
       #  Determine that folder exists
       if [ -d ${m} ]; then
          #  Copy to S3 folder and log to file
          /usr/bin/s3cmd sync ${m}/ s3://aha-life-sys/$ENVIRONMENT/$SERVER/$DAY${m}/ 2>&1 >> /var/log/s3_backup.log
       else
          echo "ERROR: Invalid directory = ${m}" | /usr/bin/logger -t s3_backup -s
       fi
   done
else
   echo "ERROR: Invalid directories = $FOLDERS" | /usr/bin/logger -t s3_backup -s
fi

#  Backup crontab
cd /tmp
/usr/bin/crontab -l >> crontab.txt
/usr/bin/s3cmd sync crontab.txt s3://aha-life-sys/$ENVIRONMENT/$SERVER/$DAY/crontab.txt 2>&1 >> /var/log/s3_backup.log
rm -rf crontab.txt

#  Create dir log of days when executed
mkdir -p ~/.s3_history
touch ~/.s3_history/`date +%F__%A_%p__%I.%M.%p`
/usr/bin/s3cmd sync ~/.s3_history/ s3://aha-life-sys/$ENVIRONMENT/$SERVER/.s3_history/ 2>&1 >> /var/log/s3_backup.log

exit 0
