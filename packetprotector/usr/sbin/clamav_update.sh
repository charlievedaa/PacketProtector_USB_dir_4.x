#!/bin/sh

export LD_LIBRARY_PATH=/packetprotector/usr/lib
export CURL_CA_BUNDLE=/packetprotector/usr/sbin/curl-ca-bundle.crt
export PATH=$PATH:/packetprotector/usr/sbin

mydate=`date +%Y%m%d%H%M`

#TOTAL_SIG_COUNT=150000
TOTAL_SIG_COUNT=100000
CONFIG_FILE="/etc/packetprotector.conf"
PROXY=`grep "dansguardian=" $CONFIG_FILE | cut -d "=" -f 2`

# Moved if down to bottom, so update will always happen,
#  regardless of if its enabled or not.
#if [ "X$PROXY" = "X1" ] ; then

	cd /packetprotector/tmp
	mkdir clamav
	cd clamav

	#FETCH DAILY UPDATES
# 	other dns names: database.clamav.net or db.US.clamav.net
# 	Create log if desired.
#	cp -pf /packetprotector/logs/clam-update.log /packetprotector/logs/clam-update.$mydate
#	echo "About to fetch" > /packetprotector/logs/clam-update.log
#	nslookup db.local.clamav.net >> /packetprotector/logs/clam-update.log
#	Change wget to curl
#	wget http://db.local.clamav.net/daily.cvd
	curl -# --user-agent clamav/0.96.3 http://db.local.clamav.net/daily.cvd -O
	if [ $? -ne 0 ] ; then
#		echo "failed to fetch" >> /packetprotector/logs/clam-update.log
		echo "Failed to fetch daily.cvd!"
		rm -rf /packetprotector/tmp/clamav
		exit
	fi
	echo "Fetch succeeded"
#	echo "Fetch succeeded" >> /packetprotector/logs/clam-update.log
#	echo "pre-unpack" >> /packetprotector/logs/clam-update.log
#	ls -al >> /packetprotector/logs/clam-update.log
	/packetprotector/usr/sbin/sigtool --unpack=./daily.cvd
#	echo "post-unpack" >> /packetprotector/logs/clam-update.log
#	ls -al >> /packetprotector/logs/clam-update.log

	DAILY_SIG_COUNT=`cat daily.mdb | wc -l`
	echo "daily sig count - " $DAILY_SIG_COUNT
	MAIN_SIG_COUNT=`expr $TOTAL_SIG_COUNT - $DAILY_SIG_COUNT`
	echo "main sig count - " $MAIN_SIG_COUNT

	#REMOVE OLD FILES
	rm -f /packetprotector/usr/share/clamav/daily.mdb
	rm -f /packetprotector/usr/share/clamav/main.mdb

	#UPDATE SIGNATURES
	if [ $MAIN_SIG_COUNT -gt 0 ] ; then
		cp daily.mdb /packetprotector/usr/share/clamav
		#RANDOM_START=$((($RANDOM*$RANDOM)%$MAIN_SIG_COUNT))
		#tail -n+$RANDOM_START /packetprotector/usr/share/clamav/main.mdb.FULL | head -$MAIN_SIG_COUNT > main.mdb
		#CURRENT_SIG_COUNT=`cat main.mdb | wc -l`
		#REMAINING_SIG_COUNT=`expr $MAIN_SIG_COUNT - $CURRENT_SIG_COUNT`
		#if [ $REMAINING_SIG_COUNT -gt 0 ] ; then
		#	head -$REMAINING_SIG_COUNT /packetprotector/usr/share/clamav/main.mdb.FULL >> main.mdb 
		#fi
		#cp main.mdb /packetprotector/usr/share/clamav/
		tail -$MAIN_SIG_COUNT /packetprotector/usr/share/clamav/main.mdb.FULL > /packetprotector/usr/share/clamav/main.mdb
	else
		tail -$TOTAL_SIG_COUNT daily.mdb > /packetprotector/usr/share/clamav/daily.mdb
	fi

	#FETCH HOTLISTS
	cd /packetprotector/tmp/clamav
#	wget http://packetprotector.org/download/hotlist.mdb
#	wget http://packetprotector.org/download/hotlist.ndb
	curl -s https://packetprotector.org/download/hotlist.mdb -O
	curl -s https://packetprotector.org/download/hotlist.ndb -O
	if [ $? -ne 0 ] ; then
		echo "Failed to fetch hotlist!"
	else
		cp hotlist.mdb /packetprotector/usr/share/clamav/
		cp hotlist.ndb /packetprotector/usr/share/clamav/
	fi

	#CLEANUP TMP DIR
	rm -rf /packetprotector/tmp/clamav

date "+%a %b %d %H:%M:%S %Y" > /packetprotector/usr/share/clamav/last_updated

# Change to bring this test down here, so update can run
#   regardless of proxy being enabled.
# Here we test if enabled and reload the new db.
#if [ "X$PROXY" = "X1" ] ; then	
#	echo RELOAD | /packetprotector/usr/sbin/socat - /tmp/clamd
#	echo 'Done.'
#	echo "Reloaded clam DB" >> /packetprotector/logs/clam-update.log
#fi
