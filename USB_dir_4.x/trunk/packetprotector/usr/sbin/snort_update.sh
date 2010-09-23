#!/bin/sh
#

export LD_LIBRARY_PATH=/packetprotector/usr/lib
export PATH=$PATH:/packetprotector/usr/sbin

SNORT_INLINE=`grep "snort-inline=" /etc/packetprotector.conf | cut -d "=" -f 2`

	if [ ! -d /packetprotector/tmp/oink/ ] ; then
		mkdir -p /packetprotector/tmp/oink/rules/drop-rules
	fi
	cd /packetprotector/tmp/oink

if [ -s /packetprotector/etc/snort/oinkcode ] ; then

	echo "Oinkcode found!"  

	OINKCODE=`cat /packetprotector/etc/snort/oinkcode | sed s/" "/""/g`

	backdoor_rule_count=200
	web_client_rule_count=300

	VRT_RULES=http://www.snort.org/pub-bin/oinkmaster.cgi/$OINKCODE/snortrules-snapshot-2860.tar.gz
	VRT_RULES_MD5=http://www.snort.org/pub-bin/oinkmaster.cgi/$OINKCODE/snortrules-snapshot-2860.tar.gz.md5

	### test if this is a new VRT ruleset via the md5 file, skip if same
	if [ ! -e /packetprotector/etc/snort/drop-rules/snortrules-snapshot-2860.tar.gz.md5.OLD ] ; then
		touch /packetprotector/etc/snort/drop-rules/snortrules-snapshot-2860.tar.gz.md5.OLD
	fi
	curl -L -# $VRT_RULES_MD5 -O || return
	diff -s snortrules-snapshot-2860.tar.gz.md5 /packetprotector/etc/snort/drop-rules/snortrules-snapshot-2860.tar.gz.md5.OLD
	
	if [ $? = 1 ]; then
		cp snortrules-snapshot-2860.tar.gz.md5 /packetprotector/etc/snort/drop-rules/snortrules-snapshot-2860.tar.gz.md5.OLD
		echo "Fetching VRT rules!"
		curl -L -# $VRT_RULES -O || return
		tar -zxvf snortrules-snapshot-CURRENT.tar.gz rules/ > /dev/null 2> /dev/null
		echo "Rules extracted!"

		if [ -s snortrules-snapshot-CURRENT.tar.gz ] ; then
			cd rules
			cp /packetprotector/etc/snort/snort-inline.conf .
			cp VRT-License.txt drop-rules/

			### setup backdoor rules
			grep -e "^alert" backdoor.rules | tail -$backdoor_rule_count | sed "s/^alert/drop/"  > drop-rules/backdoor.rules
			grep -e "^include \$RULE_PATH/backdoor.rules" snort-inline.conf > /dev/null
			if [ $? = 0 ] ; then
				echo "backdoor.rules found in snort-inline.conf"
			else
				echo "include \$RULE_PATH/backdoor.rules" >> snort-inline.conf
			fi

			### setup web-client rules
			grep -e "^alert" web-client.rules | tail -$web_client_rule_count | sed "s/^alert/drop/"  > drop-rules/web-client.rules
			grep -e "^include \$RULE_PATH/web-client.rules" snort-inline.conf > /dev/null
			if [ $? = 0 ] ; then
				echo "web-client.rules found in snort-inline.conf"
			else
				echo "include \$RULE_PATH/web-client.rules" >> snort-inline.conf
			fi
		fi
	else
		echo "New VRT Rules are same as current VRT Rules!"
	fi
else
	echo "Oinkcode not found!"
fi

# My code for updating the MTC snort ruleset at http://mtc.sri.com/live_data/signatures/
cd /packetprotector/tmp/oink/rules
cp -f /packetprotector/etc/snort/snort-inline.conf .
curl -s http://mtc.sri.com/live_data/signatures/ -o linkpage.html
FILESIZE=`ls -l linkpage.html | awk '{print $5}'`

if [ $FILESIZE -lt 5000 ] ; then
	echo "Failed to fetch mtc linkpage"
	return
else
	DLLINK=`grep Ruleset.html linkpage.html | cut -d \" -f 2`
	curl -# $DLLINK -o mtc-malware.rules
	FILESIZE=`ls -l mtc-malware.rules | awk '{print $5}'`
	if [ $FILESIZE -gt 20000 ] ; then
		echo "Fetched mtc rules"
		### setup mtc rules
		# Next line does all rules unchanged. Bogons are too broad though.
		#grep -e "^alert" mtc-malware.rules | sed "s/^alert/drop/"  > drop-rules/mtc-malware.rules
		BOGONS2="50.0.0.0\/8,100.0.0.0\/6,104.0.0.0\/6,169.254.0.0\/16,172.16.0.0\/12,176.0.0.0\/7,179.0.0.0\/8,181.0.0.0\/8,185.0.0.0\/8"
		grep "Bogon Nets 2" mtc-malware.rules | sed "s/\[.*\]/\[$BOGONS2\]/" | sed "s/^alert/drop/" > drop-rules/mtc-malware.rules
		grep -e "^alert" mtc-malware.rules | grep -v "Bogon Nets 2" | grep -v session | sed "s/^alert/drop/"  >> drop-rules/mtc-malware.rules
		# End Bogon2 code
		grep -e "^include \$RULE_PATH/mtc-malware.rules" snort-inline.conf > /dev/null
		if [ $? = 0 ] ; then
			echo "mtc-malware.rules found in snort-inline.conf"
		else
			echo "include \$RULE_PATH/mtc-malware.rules" >> snort-inline.conf
		fi
	fi
	#TEST If new MTC download (post-conversion) is same as whats in use, if it is, delete the download
	#Needs to be done by filesize as the rule order changes
	NEWFILESIZE=`ls -l ./drop-rules/mtc-malware.rules | awk '{print $5}'`
	if [ -f /packetprotector/etc/snort/drop-rules/mtc-malware.rules ] ; then
		CURRENTFILESIZE=`ls -l /packetprotector/etc/snort/drop-rules/mtc-malware.rules | awk '{print $5}'`
	else
		CURRENTFILESIZE=0
	fi
	if [ $NEWFILESIZE -eq $CURRENTFILESIZE ]; then
		rm -f mtc-malware.rules
	fi
	
fi
# End my mtc update code

#TEST For any .rules files. If exist continue.
ls *.rules > /dev/null 2> /dev/null
if [ $? = 0 ] ; then
	# My code to copy ALL the rules to a new directory so I can see/use them later
	if [ ! -d /packetprotector/etc/snort/all-rules ] ; then
		mkdir /packetprotector/etc/snort/all-rules
	fi
	cp -fp *.rules /packetprotector/etc/snort/all-rules

	### copy to /packetprotector/etc/snort/drop-rules
	# rm -rf /packetprotector/etc/snort/drop-rules.OLD
	# rm -f /packetprotector/etc/snort/snort-inline.conf.OLD
	cp -af /packetprotector/etc/snort/drop-rules /packetprotector/etc/snort/drop-rules.OLD
	cp -f /packetprotector/etc/snort/snort-inline.conf /packetprotector/etc/snort/snort-inline.conf.OLD
	cp -f drop-rules/* /packetprotector/etc/snort/drop-rules
	cp -f snort-inline.conf /packetprotector/etc/snort/

	### test new rules
	/packetprotector/usr/sbin/snort-inline -QT -c /packetprotector/etc/snort/snort-inline.conf #> /dev/null 2> /dev/null
	
	if [ $? = 0 ]; then
		echo "Snort test succeeded!  Rotating alert file."
		# update timestamp
		date "+%a %b %d %H:%M:%S %Y" > /packetprotector/etc/snort/drop-rules/last_checked
		date "+%a %b %d %H:%M:%S %Y" > /packetprotector/etc/snort/drop-rules/last_updated
		# My test
		if [ "X$SNORT_INLINE" = "X1" ] ; then
			mydate=`date +%Y%m%d%H%M`
			LOGDIR="/packetprotector/logs"
			mv $LOGDIR/snort-inline/alert $LOGDIR/snort-inline/alert.$mydate && touch $LOGDIR/snort-inline/alert
			# restart snort
			killall -1 snort-inline 2> /dev/null
			echo "Snort killed! Snort will restart shortly via watchdog..."
			# snort will get restarted by the watchdog, so next line is rem'ed
	#		/packetprotector/etc/init.d/S11snort-inline
			echo "Done!"
		fi
	else
		echo "Snort test failed!  Restoring old signatures."
		rm -rf /packetprotector/etc/snort/drop-rules
		rm -f /packetprotector/etc/snort/snort-inline.conf
		mv /packetprotector/etc/snort/drop-rules.OLD /packetprotector/etc/snort/drop-rules
		mv /packetprotector/etc/snort/snort-inline.conf.OLD /packetprotector/etc/snort/snort-inline.conf
	fi
else
	# last checked timestamp
	date "+%a %b %d %H:%M:%S %Y" > /packetprotector/etc/snort/drop-rules/last_checked
	echo "Nothing to do."	
fi

cd
rm -rf /packetprotector/tmp/oink

