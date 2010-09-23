#!/usr/bin/webif-page
<? 
. /usr/lib/webif/webif.sh

header "Network" "OpenDNS" "@TR<<OpenDNS Settings>>"

if [ "$FORM_enabled" ] ; then
        if [ "X$FORM_enabled" = "X1" ] ; then
		uci set dhcp.@dnsmasq[0].resolvfile=/tmp/resolv.conf
		rm /etc/resolv.conf; ln -s /tmp/resolv.conf /etc/resolv.conf
        elif [ "X$FORM_enabled" = "X0" ] ; then
		uci set dhcp.@dnsmasq[0].resolvfile=/tmp/resolv.conf.auto
		rm /etc/resolv.conf; ln -s /tmp/resolv.conf.auto /etc/resolv.conf
        else
                echo 'Invalid value for variable "enabled".'
        fi
uci commit
/etc/init.d/dnsmasq restart
fi

OPENDNS=`uci get dhcp.@dnsmasq[0].resolvfile`

echo '<form enctype="multipart/form-data" method="post">'
if [ "X$OPENDNS" = "X/tmp/resolv.conf" ] ; then
	echo '<input type="radio" name="enabled" value="1" checked> Enabled'
	echo '<input type="radio" name="enabled" value="0"> Disabled'
else
	echo '<input type="radio" name="enabled" value="1"> Enabled'
	echo '<input type="radio" name="enabled" value="0" checked> Disabled'
fi
echo '<input type="submit" name="submit_enabled" value="Submit">'
echo '</form>'
echo '<br />'


footer ?>
<!--
##WEBIF:name:Network:450:OpenDNS
-->
