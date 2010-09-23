#!/usr/bin/webif-page
<? 
. /usr/lib/webif/webif.sh

header "IPS" "Log" "@TR<<Snort-inline Log>>"

LD_LIBRARY_PATH=/packetprotector/usr/lib/

if [ ! -e /bin/tac ] ; then
	ln -s /packetprotector/usr/sbin/tac /bin/tac
fi
if [ ! -e /bin/tcpdump ] ; then
	ln -s /packetprotector/usr/sbin/tcpdump /bin/tcpdump
fi

if [ "$FORM_IP" ] ; then
	echo 'Displaying activity for '$FORM_IP' (oldest to newest)-<br /><br />'
	echo '<pre>'
	for i in `ls -rt /packetprotector/logs/snort-inline/snort.log*`; do
		tcpdump -n -X -r $i host $FORM_IP 2> /dev/null | sed "s/>/\&gt;/g" | sed "s/</\&lt;/g" || echo 'Error retrieving logs!<br />';
	done 
	echo '</pre>'

else	

   SNORT_INLINE_ENABLED=`egrep "^snort-inline=" /etc/packetprotector.conf | cut -d "=" -f 2`

   if [ "X$SNORT_INLINE_ENABLED" = "X1" ] ; then

	START=1
	END=50
	if [ "$FORM_start" ] && [ "$FORM_end" ] ; then
		START=$FORM_start
		END=$FORM_end
	fi
# Tail isnt used anymore
#TAIL=`expr $END - $START + 1`

	# The alerts are multi-line so the count is wrong in this calculation
#	TOTAL=`wc -l /packetprotector/logs/snort-inline/alert* | tail -1 | cut -d"t" -f1 | cut -d"/" -f1 | sed "s/ *//"`

	# My calculation first one is ALL files, second just most recent
	TOTAL=`egrep -ch ^$ /packetprotector/logs/snort-inline/alert* | awk '{sum+=$1}END{print sum}'`

        if [ "$TOTAL" -eq 0 ] ; then
                echo 'No alerts.'
	
	elif [ "$TOTAL" -eq 1 ] ; then
			echo 'Displaying '$START' of '$TOTAL' record.<br />'

	elif [ "$TOTAL" -lt $END ] ; then
		echo 'Displaying '$START' through '$TOTAL' of '$TOTAL' records.<br />'
# Tail isnt used anymore
#		TAIL=`expr $TOTAL - $START + 1`
		#PREVIOUS
		if [ "$START" -gt 50 ] ; then
			PREVIOUS_START=`expr $START - 50`
			PREVIOUS_END=`expr $END - 50`	
			echo '<a href=/cgi-bin/webif/snort-inline-log.sh?start='$PREVIOUS_START'&end='$PREVIOUS_END'>Previous</a><br />'
		fi

	else
		echo 'Displaying '$START' through '$END' of '$TOTAL' records.<br />'
		#PREVIOUS
		if [ "$START" -gt 50 ] ; then
			PREVIOUS_START=`expr $START - 50`
			PREVIOUS_END=`expr $END - 50`	
			echo '<a href=/cgi-bin/webif/snort-inline-log.sh?start='$PREVIOUS_START'&end='$PREVIOUS_END'>Previous</a><br />'
		fi
		#NEXT
		NEXT_START=`expr $START + 50`
		NEXT_END=`expr $END + 50`
		echo '<a href=/cgi-bin/webif/snort-inline-log.sh?start='$NEXT_START'&end='$NEXT_END'>Next</a><br />'
 
	fi
	echo '<br />'

	echo '<pre>'
	
# Old code: probs with printing and sig-id lookup, maybe logic as well
#	ls -t /tmp/log/snort-inline/alert* | xargs tac 2> /dev/null | head -$END | tail -$TAIL | sed "s/\[\([0-9]\{1,9\}\):\([0-9]\{1,9\}\):\([0-9]\{1,9\}\)\]/\[\1:\<a href=http:\/\/www.snort.org\/pub-bin\/sigs.cgi?sid=\1:\2 style=\"text-decoration:none\"\>\2\<\/a\>:\3\]/" | sed "s/[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}/\<a href=\/cgi-bin\/webif\/snort-inline-log.sh?IP=& style=\"text-decoration:none\"\>&\<\/a\>/g" | /packetprotector/usr/sbin/fold -s -w 120

# New code
	ls -t /packetprotector/logs/snort-inline/alert* | xargs tac 2> /dev/null | awk 'BEGIN { RS = "\n\n"; ORS = "\n\n" } NR == '$START', NR == '$END' { print }' | sed "s/\[\([0-9]\{1,9\}\):\([0-9]\{1,9\}\):\([0-9]\{1,9\}\)\]/\[\1:\<a href=http:\/\/www.snortid.com\/snortid.asp?QueryID=\1:\2 style=\"text-decoration:none\"\>\2\<\/a\>:\3\]/" | sed "s/[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}/\<a href=\/cgi-bin\/webif\/snort-inline-log.sh?IP=& style=\"text-decoration:none\"\>&\<\/a\>/g" | /packetprotector/usr/sbin/fold -s -w 120
#End new code
	echo '</pre>'

   else
        echo 'Snort-inline is not enabled.  See the <a href=/cgi-bin/webif/snort-inline-settings.sh>IPS Settings</a> page.'

   fi

fi

footer ?>
<!--
##WEBIF:name:IPS:1:Log
-->
