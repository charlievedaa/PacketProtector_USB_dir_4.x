#!/usr/bin/webif-page
<? 
. /usr/lib/webif/webif.sh

header "Proxy" "Settings" "@TR<<Proxy Settings>>"

prepare_files()
{
        if [ -h /etc/packetprotector.conf ] ; then
                cp /etc/packetprotector.conf /etc/packetprotector.conf.ORIG
                rm /etc/packetprotector.conf
                cp /rom/etc/packetprotector.conf /etc/packetprotector.conf
        fi
}

proxy_stop()
{
	/packetprotector/usr/sbin/http_unredirect.sh
	#Fixed 2/14/08.  Thanks cmh714!
	echo 'Redirection disabled.'
	echo '<br />'
	killall dansguardian 2> /dev/null
	killall tinyproxy 2> /dev/null 
	#killall clamd 2> /dev/null 

	# My Code to fix clamd stopping
	# Works with clamd.conf setting PidFile "/var/run/clamd.pid"
	# additionally, you need to rem the killall clamd statement above
	echo '' >> "/var/run/clamd.pid"
	CLAMD_PID=`cat /var/run/clamd.pid`
	kill -9 $CLAMD_PID
	# End my test code

	echo 'Waiting for DansGuardian processes to terminate...'
	echo '<br />'
	echo '<pre>'
	DG_RUNNING=1
	DG_PID=`cat /var/run/dansguardian.pid`
	while [ $DG_RUNNING = 1 ] ; do
		ps -w | grep -e "^ *$DG_PID" 
		if [ $? != 0 ] ; then
			DG_RUNNING=0
		fi
		sleep 2
	done
	echo '</pre>'
	echo '<br />'
	echo 'Done.'
	echo '<br /><br />'
}

export LD_LIBRARY_PATH=/packetprotector/usr/lib
BASEDIR="/packetprotector"
PROXY_ENABLED=`egrep "^dansguardian=" /etc/packetprotector.conf | cut -d "=" -f 2`
CF_ENABLED=`egrep "^dansguardian_cf=" /etc/packetprotector.conf | cut -d "=" -f 2`
AV_ENABLED=`egrep "^dansguardian_av=" /etc/packetprotector.conf | cut -d "=" -f 2`

if [ "$FORM_enabled" ] ; then
        if [ "X$FORM_enabled" = "X1" ] ; then
                if [ "X$PROXY_ENABLED" = "X1" ] ; then
			prepare_files
                        touch /etc/packetprotector.conf
                else
			prepare_files
                        /bin/sed -i "s/^dansguardian=.*/dansguardian=1/" /etc/packetprotector.conf
			echo 'Starting Dansguardian... (this will take a few minutes)'
			echo '<pre>'
			$BASEDIR/etc/init.d/S98dansguardian > /dev/null
			echo '</pre>'
                fi
                echo '<br />Enabled.'
                echo '<br /><br />'
        elif [ "X$FORM_enabled" = "X0" ] ; then
                if [ "X$PROXY_ENABLED" = "X1" ] ; then
			prepare_files
			proxy_stop
                        /bin/sed -i "s/^dansguardian=.*/dansguardian=0/" /etc/packetprotector.conf
                fi
                echo 'Disabled.'
                echo '<br /><br />'
        else
                echo 'Invalid value for variable "enabled".'
        fi
fi

if [ "$FORM_cfenabled" ] ; then
        if [ "X$FORM_cfenabled" = "X1" ] ; then
                if [ "X$CF_ENABLED" = "X1" ] ; then
			prepare_files
                        touch /etc/packetprotector.conf
                else
			prepare_files
                        /bin/sed -i "s/^dansguardian_cf=.*/dansguardian_cf=1/" /etc/packetprotector.conf
			echo '<pre>'
			cp /$BASEDIR/etc/dansguardian/lists/weightedphraselist.FILTERED /$BASEDIR/etc/dansguardian/lists/weightedphraselist
			echo 'Restarting Dansguardian.  This will take a couple of minutes.'
			proxy_stop
			sleep 5
			echo 'Stopped.'
			echo 'Starting...'
			$BASEDIR/etc/init.d/S98dansguardian > /dev/null
			echo '</pre>'
                fi
                echo '<br />Content filter enabled.'
                echo '<br /><br />'
        elif [ "X$FORM_cfenabled" = "X0" ] ; then
                if [ "X$CF_ENABLED" = "X1" ] ; then
			prepare_files
			cp /$BASEDIR/etc/dansguardian/lists/weightedphraselist.OPEN /$BASEDIR/etc/dansguardian/lists/weightedphraselist
                        /bin/sed -i "s/^dansguardian_cf=.*/dansguardian_cf=0/" /etc/packetprotector.conf
			echo '<pre>'
			echo 'Restarting Dansguardian.  This will take a couple of minutes.'
			proxy_stop
			sleep 5
			echo 'Stopped.'
			echo 'Starting...'
			$BASEDIR/etc/init.d/S98dansguardian > /dev/null
			echo '</pre>'
                fi
                echo 'Content filter disabled.'
                echo '<br /><br />'
        else
                echo 'Invalid value for variable "cfenabled".'
        fi
fi

#AV setting
if [ "$FORM_avenabled" ] ; then
        if [ "X$FORM_avenabled" = "X1" ] ; then
                if [ "X$AV_ENABLED" = "X1" ] ; then
			prepare_files
                        touch /etc/packetprotector.conf
                else
			prepare_files
                        /bin/sed -i "s/^dansguardian_av=.*/dansguardian_av=1/" /etc/packetprotector.conf
			/bin/sed -i "s/^# contentscanner =.*/contentscanner = '\/packetprotector\/etc\/dansguardian\/contentscanners\/clamdscan.conf'/" /packetprotector/etc/dansguardian/dansguardian.conf
			echo '<pre>'
			echo 'Restarting Dansguardian.  This will take a couple of minutes.'
			proxy_stop
			sleep 5
			echo 'Stopped.'
			echo 'Starting...'
			$BASEDIR/etc/init.d/S98dansguardian > /dev/null
			echo '</pre>'
                fi
                echo '<br />Antivirus enabled.'
                echo '<br /><br />'
        elif [ "X$FORM_avenabled" = "X0" ] ; then
                if [ "X$AV_ENABLED" = "X1" ] ; then
			prepare_files
                        /bin/sed -i "s/^dansguardian_av=.*/dansguardian_av=0/" /etc/packetprotector.conf
			/bin/sed -i "s/^contentscanner =.*/# &/" /packetprotector/etc/dansguardian/dansguardian.conf
			echo '<pre>'
			echo 'Restarting Dansguardian.  This will take a couple of minutes.'
			proxy_stop
			sleep 5
			echo 'Stopped.'
			echo 'Starting...'
			$BASEDIR/etc/init.d/S98dansguardian > /dev/null
			echo '</pre>'
                fi
                echo 'Antivirus disabled.'
                echo '<br /><br />'
        else
                echo 'Invalid value for variable "avenabled".'
        fi
fi


PROXY_ENABLED=`egrep "^dansguardian=" /etc/packetprotector.conf | cut -d "=" -f 2`
CF_ENABLED=`egrep "^dansguardian_cf=" /etc/packetprotector.conf | cut -d "=" -f 2`
AV_ENABLED=`egrep "^dansguardian_av=" /etc/packetprotector.conf | cut -d "=" -f 2`
echo '<form enctype="multipart/form-data" method="post">'
echo 'Proxy (DansGuardian + Tinyproxy)-<br />'
if [ "X$PROXY_ENABLED" = "X1" ] ; then
	echo '<input type="radio" name="enabled" value="1" checked> Enabled'
	echo '<input type="radio" name="enabled" value="0"> Disabled'
else
	echo '<input type="radio" name="enabled" value="1"> Enabled'
	echo '<input type="radio" name="enabled" value="0" checked> Disabled'
fi
echo '<input type="submit" name="submit_enabled" value="Submit">'
echo '</form>'

echo '<form enctype="multipart/form-data" method="post">'
if [ "X$PROXY_ENABLED" = "X1" ] ; then
	echo '<br />'
	echo '<form enctype="multipart/form-data" method="post">'
	CF_ENABLED=`egrep "^dansguardian_cf=" /etc/packetprotector.conf | cut -d "=" -f 2`
	echo 'Content filter (pornography, gambling, etc.)-<br />'
	if [ "X$CF_ENABLED" = "X1" ] ; then
		echo '<input type="radio" name="cfenabled" value="1" checked> Enabled'
		echo '<input type="radio" name="cfenabled" value="0"> Disabled'
	else
		echo '<input type="radio" name="cfenabled" value="1"> Enabled'
		echo '<input type="radio" name="cfenabled" value="0" checked> Disabled'
	fi
	echo '<input type="submit" name="submit_cf" value="Submit">'
	echo '</form>'
	
fi

#AV setting
if [ "X$PROXY_ENABLED" = "X1" ] ; then
	echo '<br />'
	echo '<form enctype="multipart/form-data" method="post">'
	AV_ENABLED=`egrep "^dansguardian_av=" /etc/packetprotector.conf | cut -d "=" -f 2`
	echo 'Antivirus (ClamAV)-<br />'
	if [ "X$AV_ENABLED" = "X1" ] ; then
		echo '<input type="radio" name="avenabled" value="1" checked> Enabled'
		echo '<input type="radio" name="avenabled" value="0"> Disabled'
	else
		echo '<input type="radio" name="avenabled" value="1"> Enabled'
		echo '<input type="radio" name="avenabled" value="0" checked> Disabled'
	fi
	echo '<input type="submit" name="submit_av" value="Submit">'
	echo '</form>'
	
fi

echo '<br />'

# My stuff for changing the number of signatures in use
# CURR_SIG_COUNT=`cat /packetprotector/usr/share/clamav/daily.mdb | wc -l`
echo 'Current signature count- ' $CURR_SIG_COUNT '<br />'
echo '<pre>'
cd /packetprotector/usr/share/clamav; wc -l *db
echo '</pre>'
echo '<br />'

if [ "$FORM_signatures" ] ; then
	/bin/sed -i "s/^TOTAL_SIG_COUNT=.*/TOTAL_SIG_COUNT="$FORM_signatures"/" /packetprotector/usr/sbin/clamav_update.sh
fi

NEW_SIG_COUNT=`grep ^TOTAL_SIG_COUNT= /packetprotector/usr/sbin/clamav_update.sh | cut -d= -f2`
echo '<form enctype="multipart/form-data" method="post">'
echo '<table><tr>'
echo '<td>Number of signatures to install at next update-  <input type="text" size="10" name="signatures" value="'$NEW_SIG_COUNT'">'
echo '<td><input type="submit" name="submit_signatures" value="Submit">'
echo '</form>'
echo '</tr></table>'
echo '<br />'
# End my stuff

LAST_UPDATED=`cat /packetprotector/usr/share/clamav/last_updated`
echo 'Signatures last updated '$LAST_UPDATED'.'
echo '<br /><br />'

footer ?>
<!--
##WEBIF:name:Proxy:2:Settings
-->
