#!/bin/bash

#-----------------------------------------------------------------------
#
#  T O M C A T _ C R E A T E _ A P P . S H
#
#  Create additional Tomcat7 App instances.
#  Site 2: UI
#  Site 3: OPERATIONS
#  Site 4: CONSOLE
#  Site 5: API
#  Site 6: TAG CONSOLE
#
#-----------------------------------------------------------------------

#----------------------------
#
#  Validate Parameters
#
#----------------------------

##  Get APP name
if [ $# != 1 ]; then
	echo -e "Usage: $0 tag | api | console | ops | ui "
	exit 0
fi

##  Check it's a Tomcat7 server
if [ ! -d /etc/tomcat7 ]; then
	echo "ERROR: This is NOT a Tomcat7 server (missing /etc/tomcat7 folder)"
	exit 0
fi

##  Determine which app
MYAPP=$(echo $1 | tr '[:upper:]' '[:lower:]')
#  Verify that environment is an approved value
if ! [[ "$MYAPP" == "tag" || "$MYAPP" == "console" || "$MYAPP" == "api" || "$MYAPP" == "ui" || "$MYAPP" == "ops" ]]; then
	echo "ERROR: Invalid Tomcat App value: $MYAPP (only allowed = tag | console | api | ui | ops)"
	exit 0
fi

#  Determine APP name
case $MYAPP in
	tag )
		APP='tomcat7tag'
 		;;
	api )
		APP='tomcat7api'
 		;;
	console )
		APP='tomcat7console'
		;;
	ops )
		APP='tomcat7ops'
 		;;
	ui )
		APP='tomcat7ui'
 		;;
esac

##  Stop and remove old daemon
if [ -f /etc/init.d/$APP ]; then
	/usr/sbin/service $APP stop
	/bin/sleep 5
	/usr/sbin/update-rc.d -f $APP remove
fi

##  Remove Old App folders
if [ -d /etc/$APP ]; then rm -rf /etc/$APP; fi
if [ -d /usr/share/$APP ]; then rm -rf /usr/share/$APP; fi
if [ -d /var/cache/$APP ]; then rm -rf /var/cache/$APP; fi
if [ -d /var/lib/$APP ]; then rm -rf /var/lib/$APP; fi
if [ -d /var/log/$APP ]; then rm -rf /var/log/$APP; fi

##  Copy folders
cp -R --preserve /etc/tomcat7 /etc/$APP
cp -R --preserve /usr/share/tomcat7 /usr/share/$APP
cp -R --preserve /var/cache/tomcat7 /var/cache/$APP
cp -R --preserve /var/lib/tomcat7 /var/lib/$APP
cp -R --preserve /var/log/tomcat7 /var/log/$APP

##  Reset symlinks to new app folders
if [ -d /var/lib/$APP ]; then
	rm -f /var/lib/$APP/conf
	rm -f /var/lib/$APP/logs
	rm -f /var/lib/$APP/work
	cd /var/lib/$APP
	ln -s /etc/$APP conf
	ln -s ../../log/$APP logs
	ln -s ../../cache/$APP work
fi

##  Cleanup old log files
cat /dev/null > /var/log/$APP/catalina.out
cat /dev/null > /var/log/$APP/catalina.log
cat /dev/null > /var/log/$APP/localhost.log
cat /dev/null > /var/log/$APP/host-manager.log
cat /dev/null > /var/log/$APP/manager.log
rm -rf /var/log/$APP/*.txt
rm -rf /var/log/$APP/*.gz

##  Copy Log rotate
if [ -f /etc/logrotate.d/$APP ]; then rm -rf /etc/logrotate.d/$APP; fi
cp --preserve /etc/logrotate.d/tomcat7 /etc/logrotate.d/$APP
sed -i 's/tomcat7\//'"$APP"'\//g' /etc/logrotate.d/$APP

##  Daemon Startup files
if [ -f /etc/init.d/$APP ]; then rm -rf /etc/init.d/$APP; fi
cp --preserve /etc/init.d/tomcat7 /etc/init.d/$APP
sed -i 's/\#\ Provides\:\ \ \ \ \ \ \ \ \ \ tomcat7/\#\ Provides\:\ \ \ \ \ \ \ \ \ \ '"$APP"'/g' /etc/init.d/$APP
sed -i 's/NAME\=tomcat7/NAME\='"$APP"'/g' /etc/init.d/$APP
sed -i 's/DESC\=\"Tomcat\ servlet\ engine\"/DESC\=\"'"$APP"'\ servlet\ engine\"/g' /etc/init.d/$APP
sed -i 's/JVM_TMP\=\/tmp\/tomcat7/JVM_TMP\=\/tmp\/'"$APP"'/g' /etc/init.d/$APP
sed -i 's/\/init\.d\/tomcat7/\/init\.d\/'"$APP"'/g' /etc/init.d/$APP
/usr/sbin/update-rc.d $APP defaults

##  Tomcat server.xml file
case $MYAPP in
	tag )
		sed -i 's/port\=\"8080\"/port\=\"8130\"/g' /etc/$APP/server.xml
		sed -i 's/redirectPort\=\"8443\"/redirectPort\=\"8493\"/g' /etc/$APP/server.xml
		sed -i 's/port\=\"8443\"/port\=\"8493\"/g' /etc/$APP/server.xml
		;;
	api )
		sed -i 's/port\=\"8080\"/port\=\"8120\"/g' /etc/$APP/server.xml
		sed -i 's/redirectPort\=\"8443\"/redirectPort\=\"8483\"/g' /etc/$APP/server.xml
		sed -i 's/port\=\"8443\"/port\=\"8483\"/g' /etc/$APP/server.xml
 		;;
	console )
		sed -i 's/port\=\"8080\"/port\=\"8110\"/g' /etc/$APP/server.xml
		sed -i 's/redirectPort\=\"8443\"/redirectPort\=\"8473\"/g' /etc/$APP/server.xml
		sed -i 's/port\=\"8443\"/port\=\"8473\"/g' /etc/$APP/server.xml
		;;
	ui )
		sed -i 's/port\=\"8080\"/port\=\"8090\"/g' /etc/$APP/server.xml
		sed -i 's/redirectPort\=\"8443\"/redirectPort\=\"8453\"/g' /etc/$APP/server.xml
		sed -i 's/port\=\"8443\"/port\=\"8453\"/g' /etc/$APP/server.xml
		;;
	ops )
		sed -i 's/port\=\"8080\"/port\=\"8100\"/g' /etc/$APP/server.xml
		sed -i 's/redirectPort\=\"8443\"/redirectPort\=\"8463\"/g' /etc/$APP/server.xml
		sed -i 's/port\=\"8443\"/port\=\"8463\"/g' /etc/$APP/server.xml
		;;
esac

##  Update Tomcat Bin Startup scripts
case $MYAPP in
	tag )
		sed -i 's/address\=8000/address\=8050/g' /usr/share/$APP/bin/catalina.sh
		sed -i 's/JPDA_ADDRESS\=\"8000\"/JPDA_ADDRESS\=\"8050\"/g' /usr/share/$APP/bin/catalina.sh
		sed -i 's/jmxremote.port\=1099/jmxremote.port\=1149/g' /usr/share/$APP/bin/setenv.sh
		sed -i 's/JPDA_ADDRESS\=\"8000\"/JPDA_ADDRESS\=\"8050\"/g' /usr/share/$APP/bin/catalina-back.sh
 		;;
	api )
		sed -i 's/address\=8000/address\=8040/g' /usr/share/$APP/bin/catalina.sh
		sed -i 's/JPDA_ADDRESS\=\"8000\"/JPDA_ADDRESS\=\"8040\"/g' /usr/share/$APP/bin/catalina.sh
		sed -i 's/jmxremote.port\=1099/jmxremote.port\=1139/g' /usr/share/$APP/bin/setenv.sh
		sed -i 's/JPDA_ADDRESS\=\"8000\"/JPDA_ADDRESS\=\"8040\"/g' /usr/share/$APP/bin/catalina-back.sh
 		;;
	console )
		sed -i 's/address\=8000/address\=8030/g' /usr/share/$APP/bin/catalina.sh
		sed -i 's/JPDA_ADDRESS\=\"8000\"/JPDA_ADDRESS\=\"8030\"/g' /usr/share/$APP/bin/catalina.sh
		sed -i 's/jmxremote.port\=1099/jmxremote.port\=1129/g' /usr/share/$APP/bin/setenv.sh
		sed -i 's/JPDA_ADDRESS\=\"8000\"/JPDA_ADDRESS\=\"8030\"/g' /usr/share/$APP/bin/catalina-back.sh
		;;
	ui )
		sed -i 's/address\=8000/address\=8010/g' /usr/share/$APP/bin/catalina.sh
		sed -i 's/JPDA_ADDRESS\=\"8000\"/JPDA_ADDRESS\=\"8010\"/g' /usr/share/$APP/bin/catalina.sh
		sed -i 's/jmxremote.port\=1099/jmxremote.port\=1109/g' /usr/share/$APP/bin/setenv.sh
		sed -i 's/JPDA_ADDRESS\=\"8000\"/JPDA_ADDRESS\=\"8010\"/g' /usr/share/$APP/bin/catalina-back.sh
 		;;
	ops )
		sed -i 's/address\=8000/address\=8020/g' /usr/share/$APP/bin/catalina.sh
		sed -i 's/JPDA_ADDRESS\=\"8000\"/JPDA_ADDRESS\=\"8020\"/g' /usr/share/$APP/bin/catalina.sh
		sed -i 's/jmxremote.port\=1099/jmxremote.port\=1119/g' /usr/share/$APP/bin/setenv.sh
		sed -i 's/JPDA_ADDRESS\=\"8000\"/JPDA_ADDRESS\=\"8020\"/g' /usr/share/$APP/bin/catalina-back.sh
 		;;
esac

##  Copy Monit script
if [ -f /etc/monit/conf.d/$APP.conf ]; then rm -rf /etc/monit/conf.d/$APP.conf; fi
cp --preserve /etc/monit/conf.d/tomcat7.conf /etc/monit/conf.d/$APP.conf
case $MYAPP in
	tag )
		sed -i 's/tomcat7/'"$APP"'/g' /etc/monit/conf.d/$APP.conf
		sed -i 's/port\ 8080/port\ 8130/g' /etc/monit/conf.d/$APP.conf
 		;;
	api )
		sed -i 's/tomcat7/'"$APP"'/g' /etc/monit/conf.d/$APP.conf
		sed -i 's/port\ 8080/port\ 8120/g' /etc/monit/conf.d/$APP.conf
 		;;
	console )
		sed -i 's/tomcat7/'"$APP"'/g' /etc/monit/conf.d/$APP.conf
		sed -i 's/port\ 8080/port\ 8110/g' /etc/monit/conf.d/$APP.conf
		;;
	ui )
		sed -i 's/tomcat7/'"$APP"'/g' /etc/monit/conf.d/$APP.conf
		sed -i 's/port\ 8080/port\ 8090/g' /etc/monit/conf.d/$APP.conf
 		;;
	ops )
		sed -i 's/tomcat7/'"$APP"'/g' /etc/monit/conf.d/$APP.conf
		sed -i 's/port\ 8080/port\ 8100/g' /etc/monit/conf.d/$APP.conf
 		;;
esac

exit 0

