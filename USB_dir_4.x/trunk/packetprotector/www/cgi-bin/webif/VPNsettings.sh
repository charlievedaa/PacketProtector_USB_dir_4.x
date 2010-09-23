#!/usr/bin/webif-page
<? 
. /usr/lib/webif/webif.sh

header "VPN" "Settings" "@TR<<VPN Settings>>"

prepare_files()
{
        if [ -h /etc/packetprotector.conf ] ; then
                cp /etc/packetprotector.conf /etc/packetprotector.conf.ORIG
                rm /etc/packetprotector.conf
                cp /rom/etc/packetprotector.conf /etc/packetprotector.conf
        fi
        if [ -h /etc/advanced_firewall.conf ] ; then
                cp /etc/advanced_firewall.conf /etc/advanced_firewall.conf.ORIG
                rm /etc/advanced_firewall.conf
                cp /rom/etc/advanced_firewall.conf /etc/advanced_firewall.conf
        fi
}

BASEDIR="/packetprotector"
OPENVPN_ENABLED=`egrep "^openvpn=" /etc/packetprotector.conf | cut -d "=" -f 2`
DH_RUNNING=`ps | grep "openssl dhparam" | grep -v grep`

if [ "$FORM_enabled" ] ; then
	if [ "X$FORM_enabled" = "X1" ] ; then
		if [ "X$OPENVPN_ENABLED" = "X1" ] ; then
			prepare_files
			touch /etc/packetprotector.conf
		else
			prepare_files
			/bin/sed -i "s/^openvpn_from_outside=block/openvpn_from_outside=unblock/" /etc/advanced_firewall.conf
			$BASEDIR/etc/firewall/openvpn_from_outside.sh unblock
			$BASEDIR/etc/init.d/S30openvpn-config 2> /dev/null > /dev/null
			$BASEDIR/etc/init.d/S31openvpn 2> /dev/null > /dev/null
			/bin/sed -i "s/^openvpn=.*/openvpn=1/" /etc/packetprotector.conf
		fi
		echo 'Enabled.'
		echo '<br /><br />'
	elif [ "X$FORM_enabled" = "X0" ] ; then
		if [ "X$OPENVPN_ENABLED" = "X1" ] ; then
			prepare_files
			killall openvpn
			/bin/sed -i "s/^openvpn=.*/openvpn=0/" /etc/packetprotector.conf
			/bin/sed -i "s/^openvpn_from_outside=unblock/openvpn_from_outside=block/" /etc/advanced_firewall.conf
			$BASEDIR/etc/firewall/openvpn_from_outside.sh block
		fi
		echo 'Disabled.'
		echo '<br /><br />'
	else 
		echo 'Invalid value for variable "enabled".'
	fi
fi

if [ $FORM_initialize ] ; then
	echo '<pre>'
	cd /etc/easy-rsa/keys
	if [ -s "dh1024.pem" ] ; then
		echo 'CA already initialized.'
		echo ''
	elif [ -n $DH_RUNNING ] ; then
		echo 'Diffie Hellman parameters are currently being generated.'
		echo ''
		echo '$DH_RUNNING'
		echo ''
		echo 'Please check back in 15-30 minutes.'
		echo '' 
	else
		cd /etc/easy-rsa
		. ./vars > /dev/null
		echo 'Generating Diffie Hellman parameters.'
		echo ''
		echo 'GET COMFORTABLE, THIS MAY TAKE 15-30 MINUTES!'
		echo ''
		./build-dh
		echo 'Completed.'
		echo ''
	fi
	echo '</pre>'
fi		

OPENVPN_ENABLED=`egrep "^openvpn=" /etc/packetprotector.conf | cut -d "=" -f 2`

echo '<form enctype="multipart/form-data" method="post">'
if [ "X$OPENVPN_ENABLED" = "X1" ] ; then
	echo '<input type="radio" name="enabled" value="1" checked> Enabled'
	echo '<input type="radio" name="enabled" value="0"> Disabled'
else
	echo '<input type="radio" name="enabled" value="1"> Enabled'
	echo '<input type="radio" name="enabled" value="0" checked> Disabled'
fi
echo '<input type="submit" name="submit_enabled" value="Submit">'
echo '</form>'
echo '<br /><br />'

if [ "X$OPENVPN_ENABLED" = "X1" ] ; then
        WAN_IP=`ifconfig \`uci get network.wan.ifname\` | grep "inet addr" | cut -c 21-35 | cut -d" " -f1`
        DYNAMIC_DNS=`uci get updatedd.cfg1.update 2> /dev/null`
        if [ "X$DYNAMIC_DNS" = "X1" ] ; then
                HOST=`uci get updatedd.cfg1.host`
                echo '<a href=/cgi-bin/webif/network-ddns.sh>Dynamic DNS</a> is enabled; using "'$HOST'" in the OpenVPN client configuration file(s).<br />'
        else
                echo '<a href=/cgi-bin/webif/network-ddns.sh>Dynamic DNS</a> is disabled; using the WAN IP address ('$WAN_IP') in the OpenVPN client configuration file(s).<br />'
        fi
        echo '<br />'

	cd /etc/easy-rsa/keys
	if [ -s "dh1024.pem" ] ; then
		echo 'CA is initialized.  Ready to accept connections.<br />'
        elif [ -n $DH_RUNNING ] ; then
                echo 'Diffie Hellman parameters are currently being generated.<br />'
                echo '<pre>$DH_RUNNING</pre><br />'
                echo 'Please check back in 15-30 minutes.<br />'
	else
		echo 'CA is not initialized.<br /><br />'
		echo '<form enctype="multipart/form-data" method="post">'
		echo 'Click <input type="submit" name="initialize" value="initialize"> to enable the local certificate authority.<br /><br />'
		echo 'WARNING- it may take 15-30 minutes to generate the Diffie Hellman parameters!<br /><br />'
	fi
fi

#echo $REMOTE_ADDR 
#echo $REMOTE_USER

footer ?>
<!--
##WEBIF:name:VPN:2:Settings
-->
