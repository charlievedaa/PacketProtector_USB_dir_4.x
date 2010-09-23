#!/bin/sh
#
# Amount of hours you want to keep.
HOURS="4"
# How often this script is run by watchdog. In our case,
#  every 15 minutes (quarter hour). Change the constant accordingly.
WDHOURS="4"

let KEEPFILES="$HOURS * $WDHOURS"

# Create a unique log file, with some info showing your status/connectivity.
# Assumes the /packetprotector/logs directory already exists.
mydate=`date +%Y%m%d%H%M`
echo `date` > /packetprotector/logs/router_up_$mydate.log
nslookup db.local.clamav.net >> /packetprotector/logs/router_up_$mydate.log
top -n1 >> /packetprotector/logs/router_up_$mydate.log

# Clean the log directory of oldest file.
NUM_FILES=`ls -l /packetprotector/logs/router_up_* | wc -l`
if [ $NUM_FILES -gt $KEEPFILES ] ; then
	rm -f `ls -tr /packetprotector/logs/router_up_*.log | head -n 1`
fi
