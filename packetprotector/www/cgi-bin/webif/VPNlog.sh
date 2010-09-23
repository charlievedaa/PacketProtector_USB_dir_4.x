#!/usr/bin/webif-page
<?
. /usr/lib/webif/webif.sh

header "VPN" "Log" "@TR<<OpenVPN Log>>"

LD_LIBRARY_PATH=/packetprotector/usr/lib/

if [ ! -e /bin/tac ] ; then
    ln -s /packetprotector/usr/sbin/tac /bin/tac
fi

if [ ! -e /bin/fold ] ; then
    ln -s /packetprotector/usr/sbin/fold /bin/fold
fi

cd /packetprotector/logs

OPENVPN_ENABLED=`egrep "^openvpn=" /etc/packetprotector.conf | cut -d "=" -f 2`

if [ "X$OPENVPN_ENABLED" = "X1" ] ; then

        TOTAL=`wc -l /packetprotector/logs/openvpn.log* 2> /dev/null | tail -1 | cut -d"t" -f1 | cut -d"/" -f1 | sed "s/ *//"`

        if [ "$TOTAL" -eq 0 ] ; then
                echo 'Logfile is empty.'

	else
    		echo '<pre>'
    		/bin/tac `ls -t /packetprotector/logs/openvpn.log*` | egrep "primary virtual IP" | /bin/fold -s -w 120
    		echo '</pre>'
	fi

else

    echo 'OpenVPN is not enabled.  See the <a href=/cgi-bin/webif/VPNsettings.sh>OpenVPN Settings</a> page.'

fi

footer ?>
<!--
##WEBIF:name:VPN:3:Log
-->
