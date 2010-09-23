#!/usr/bin/webif-page
#
# I dont believe we would ever have more than a few DENIED messages, so 
# much of the paging code below is probably unecessary.
#
# Change the SEARCH_WORD variable to what you want in this display
# Default is DENIED, which includes INFECTED
# you can use EXCEPTION as a test, since there are many of these.
<? 
. /usr/lib/webif/webif.sh

header "Proxy" "Denied Log" "@TR<<Proxy Denied Log>>"

SEARCH_WORD=DENIED

LD_LIBRARY_PATH=/packetprotector/usr/lib/

if [ ! -e /bin/tac ] ; then
	ln -s /packetprotector/usr/sbin/tac /bin/tac
fi

if [ ! -e /bin/fold ] ; then
	ln -s /packetprotector/usr/sbin/fold /bin/fold
fi

PROXY_ENABLED=`egrep "^dansguardian=" /etc/packetprotector.conf | cut -d "=" -f 2`

if [ "X$PROXY_ENABLED" = "X1" ] ; then

	START=1
	END=100
	if [ "$FORM_start" ] && [ "$FORM_end" ] ; then
		START=$FORM_start
		END=$FORM_end
	fi
	TAIL=`expr $END - $START + 1`

	cd /packetprotector/logs/dansguardian

	TOTAL=`grep $SEARCH_WORD access.log* | wc -l`

	if [ "$TOTAL" -eq 0 ] ; then
		echo 'Nothing has been denied.'

	elif [ "$TOTAL" -eq 1 ] ; then
		echo 'Displaying '$START' of '$TOTAL' records.<br />'

	elif [ "$TOTAL" -lt $END ] ; then
		echo 'Displaying '$START' through '$TOTAL' of '$TOTAL' records.<br />'
		TAIL=`expr $TOTAL - $START + 1`
		#PREVIOUS
		if [ "$START" -gt 100 ] ; then
			PREVIOUS_START=`expr $START - 100`
			PREVIOUS_END=`expr $END - 100`
#			Next if to display a jump to first page link			
			if [ "$END" -gt 200 ] ; then
				echo '<a href=/cgi-bin/webif/proxy-denies.sh?start='1'&end='100'>First Page</a><br />'
			fi
			echo '<a href=/cgi-bin/webif/proxy-denies.sh?start='$PREVIOUS_START'&end='$PREVIOUS_END'>Previous</a><br />'
		fi

	else
		echo 'Displaying '$START' through '$END' of '$TOTAL' records.<br />'
		#PREVIOUS
		if [ "$START" -gt 100 ] ; then
			PREVIOUS_START=`expr $START - 100`
			PREVIOUS_END=`expr $END - 100`
#			Next if to display a jump to first page link			
			if [ "$END" -gt 200 ] ; then
				echo '<a href=/cgi-bin/webif/proxy-denies.sh?start='1'&end='100'>First Page</a><br />'
			fi
			echo '<a href=/cgi-bin/webif/proxy-denies.sh?start='$PREVIOUS_START'&end='$PREVIOUS_END'>Previous</a><br />'
		fi
		#NEXT
		NEXT_START=`expr $START + 100`
		NEXT_END=`expr $END + 100`
		echo '<a href=/cgi-bin/webif/proxy-denies.sh?start='$NEXT_START'&end='$NEXT_END'>Next</a><br />'

		# Next if to display a jump to last page link - not elegant but works
		let LASTPAGESTART="$TOTAL / 100 * 100 + 1"
		let LASTPAGEEND="$TOTAL / 100 * 100 + 100"
		if [ "$NEXT_END" -ne "$LASTPAGEEND" ] ; then
			echo '<a href=/cgi-bin/webif/proxy-denies.sh?start='$LASTPAGESTART'&end='$LASTPAGEEND'>Last Page</a><br />'
		fi
 
	fi

	echo '<pre>'
	/bin/tac `ls -t /packetprotector/logs/dansguardian/access.log*`  | grep $SEARCH_WORD | head -$END | tail -$TAIL | /bin/fold -s -w 120
	echo '</pre>'

else

	echo 'DansGuardian is not enabled.  See the <a href=/cgi-bin/webif/proxy-settings.sh>Proxy Settings</a> page.'

fi

footer ?>
<!--
##WEBIF:name:Proxy:4:Denied Log
-->
