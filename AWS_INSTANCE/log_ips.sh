#!/bin/bash

#-----------------------------------------------------------------------
#
#  L O G _ I P S . S H
#
#  On boot/demand, log to file current external and internal IPs
#
#  NOTE: Since script MAY be called at boot, ALWAYS return 0 to
#  avoid potential endless loop by /etc/rc.local
#
#-----------------------------------------------------------------------

#  Obtain External and Internal IPs
HOST_IP_EXT=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)
HOST_IP_INT=$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)
NOW=$(date +'%F %r')

#  Record IPs to log file
echo "$NOW -- External IP: $HOST_IP_EXT, Internal IP: $HOST_IP_INT" >> /etc/xyz/server_ips.log

exit 0
