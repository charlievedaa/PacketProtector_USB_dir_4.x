#!/usr/bin/webif-page
<? 
. /usr/lib/webif/webif.sh

header "IPS" "Settings" "@TR<<Snort-inline Settings>>"

prepare_files()
{
        if [ -h /etc/packetprotector.conf ] ; then
                cp /etc/packetprotector.conf /etc/packetprotector.conf.ORIG
                rm /etc/packetprotector.conf
                cp /rom/etc/packetprotector.conf /etc/packetprotector.conf
        fi
}

BASEDIR="/packetprotector"
SNORT_INLINE_ENABLED=`egrep "^snort-inline=" /etc/packetprotector.conf | cut -d "=" -f 2`

if [ "$FORM_enabled" ] ; then
        if [ "X$FORM_enabled" = "X1" ] ; then
                if [ "X$SNORT_INLINE_ENABLED" = "X1" ] ; then
			prepare_files
                        touch /etc/packetprotector.conf
                else
			prepare_files
                        /bin/sed -i "s/^snort-inline=.*/snort-inline=1/" /etc/packetprotector.conf
			$BASEDIR/etc/init.d/S10snort-config
			$BASEDIR/etc/init.d/S11snort-inline > /dev/null
                fi
                echo '<br />Enabled.'
                echo '<br /><br />'
        elif [ "X$FORM_enabled" = "X0" ] ; then
                if [ "X$SNORT_INLINE_ENABLED" = "X1" ] ; then
			prepare_files
                        /bin/sed -i "s/^snort-inline=.*/snort-inline=0/" /etc/packetprotector.conf
                        killall snort-inline > /dev/null
			wait
			$BASEDIR/etc/init.d/S11snort-inline > /dev/null
                fi
                echo 'Disabled.'
                echo '<br /><br />'
        else
                echo 'Invalid value for variable "enabled".'
        fi
fi

if [ "$FORM_oinkcode" ] ; then
        if [ "X$FORM_oinkcode" = "X" ] ; then
		echo 'Nothing to do!'
		echo '<br /><br />'
	else
		echo "$FORM_oinkcode" > /packetprotector/etc/snort/oinkcode
		echo 'Saved!'
		echo 'Downloading VRT rules!'
		echo '<br /><br />'
		echo '<pre>'
		/packetprotector/usr/sbin/snort_update.sh
		echo '</pre>'
		echo '<br /><br />'
		echo 'Done!'
		echo '<br /><br />'
	fi
fi

if [ "$FORM_clearoinkcode" ] ; then
		cat /dev/null > /packetprotector/etc/snort/oinkcode
		echo 'Done!'
		echo '<br /><br />'
fi

if [ "$FORM_view" ] ; then
        echo '<a href=/cgi-bin/webif/snort-inline-settings.sh style="text-decoration:none">Return to settings.</a><br /><br />'
        echo '<pre>'
        FOUND=0
        for i in `ls /packetprotector/etc/snort/drop-rules/*.rules | cut -d"/" -f6`;
do
                if [ "$i" = "$FORM_view" ] ; then
                        cat /packetprotector/etc/snort/drop-rules/$FORM_view | sed "s/>/\&gt;/g" | sed "s/</\&lt;/g"
                        FOUND=1
                fi
        done

        if [ "$FOUND" = "0" ] ; then
                echo $FORM_view 'not found.'
        fi

        echo '</pre>'
        echo '<br />'
        echo '<a href=/cgi-bin/webif/snort-inline-settings.sh style="text-decoration:none">Return to settings.</a><br /><br />'

else

   SNORT_INLINE_ENABLED=`egrep "^snort-inline=" /etc/packetprotector.conf | cut -d "=" -f 2`
   echo '<form enctype="multipart/form-data" method="post">'
   if [ "X$SNORT_INLINE_ENABLED" = "X1" ] ; then
        echo '<input type="radio" name="enabled" value="1" checked> Enabled'
        echo '<input type="radio" name="enabled" value="0"> Disabled'
   else
        echo '<input type="radio" name="enabled" value="1"> Enabled'
        echo '<input type="radio" name="enabled" value="0" checked> Disabled'
   fi
   echo '<input type="submit" name="submit_enabled" value="Submit">'
   echo '</form>'
   echo '<br />'

   echo '<form enctype="multipart/form-data" method="post">'
   OINKCODE=`cat /packetprotector/etc/snort/oinkcode`
   if [ -s /packetprotector/etc/snort/oinkcode ] ; then
	echo 'Oink Code found!'
	echo '<br /><br />'
	echo 'Using VRT and MTC rules.'
   else
	echo 'Oink Code not found!'
	echo '<br /><br />'
	echo 'Using GPL and MTC rules.'
	echo '<br /><br />'
	echo 'Please register at <a href="http://snort.org">snort.org</a> to get the lastest Snort rules.  Once registered, get your Oink Code on their "Account Settings" page.'
   fi
   echo '<br /><br />'
	 
   echo '<table><tr>'
   echo '<td>Oink Code <input type="text" size="45" name="oinkcode" value="'$OINKCODE'">'
   echo '<td><input type="submit" name="submit_oinkcode" value="Submit">'
   echo '</form>'
   echo '<td><form enctype="multipart/form-data" method="post">'
   echo '<input type="hidden" name="clearoinkcode" value="1">'
   echo '<input type="submit" name="submit_clearoinkcode" value="Clear">'
   echo '</form>'
   echo '</tr></table>'
   echo '<br />' 

   echo '<b>Rules</b><br />'
   echo '<table>'
   echo '<tr>'
   echo '<td width=300>filename'
   echo '<td>enabled?'
   echo '</tr>'
   for i in `ls /packetprotector/etc/snort/drop-rules/*.rules | cut -d"/" -f6`; do
        echo '<tr>'
        echo '<td width=300><a href=/cgi-bin/webif/snort-inline-settings.sh?view='$i' style="text-decoration:none">'$i'</a>'
        ENABLED=`grep "^include \\$RULE_PATH/$i" /packetprotector/etc/snort/snort-inline.conf || echo 0`
        #echo '<td>'$ENABLED
        if [ "$ENABLED" = "0" ] ; then
                echo '<td>no'
        else
                echo '<td>yes'
        fi
        echo '</tr>'
   done

   echo '</table>'
   echo '<br />'
   echo 'Current rule count- <br />'
   echo '<table>'
   cd /packetprotector/etc/snort/drop-rules; for i in `ls *.rules` ; do echo '<tr><td width=50>'; grep -e "^drop" $i | wc -l ; echo '</td><td>' ; echo $i ; echo '</td></tr>' ; done
   echo '<tr><td>'
   grep -e "^drop" *.rules | wc -l
   echo '</td><td>'
   echo 'total'
   echo '</td></tr>'
   echo '</table>'
   echo '<br />'
   LAST_UPDATED=`cat /packetprotector/etc/snort/drop-rules/last_updated`
   echo 'Rules last updated '$LAST_UPDATED'.'
   echo '<br />'
   LAST_CHECKED=`cat /packetprotector/etc/snort/drop-rules/last_checked`
   echo 'Rules last checked '$LAST_CHECKED'.'

fi

footer ?>
<!--
##WEBIF:name:IPS:2:Settings
-->
