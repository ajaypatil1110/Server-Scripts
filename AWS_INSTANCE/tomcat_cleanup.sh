#!/bin/bash

#-----------------------------------------------------------------------
#
#  T O M C A T _ C L E A N U P . S H
#
#  Run cleanup tasks on tomcat7 severs
#
#-----------------------------------------------------------------------

#  List of Tomcat folders
TOMCAT_LOGS=( /var/log/tomcat7 /var/log/tomcat7site2 /var/log/tomcat7site3 /var/log/tomcat7site4 /var/log/tomcat7site5 /var/log/tomcat7ui /var/log/tomcat7ops /var/log/tomcat7console /var/log/tomcat7api )

#  Clear all log files
for m in "${TOMCAT_LOGS[@]}"
do
	if [ -d ${m} ]
    then
		cd ${m}
		cat /dev/null > catalina.out
		cat /dev/null > catalina.log
		cat /dev/null > localhost.log
		cat /dev/null > host-manager.log
		cat /dev/null > manager.log
		rm -rf *.txt
		rm -rf *.gz
	fi
done

exit 0

