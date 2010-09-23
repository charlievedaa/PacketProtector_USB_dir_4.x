#!/bin/sh

# Number of files you want to keep
# Since proxylogrotate runs every 15 minutes via cron
# Keeping 4 files equals 1 hour of logs
KEEPFILES="8"

mydate=`date +%Y%m%d%H%M`

cd /packetprotector/logs/dansguardian
if [ -s access.log ] ; then
	cp access.log access.log.$mydate
	cat /dev/null > access.log
fi

# Clean the log directory of oldest file.
NUM_FILES=`ls -l /packetprotector/logs/dansguardian/access.log.* | wc -l`
if [ $NUM_FILES -gt $KEEPFILES ] ; then
	rm -f `ls -tr /packetprotector/logs/dansguardian/access.log.* | head -n 1`
fi
