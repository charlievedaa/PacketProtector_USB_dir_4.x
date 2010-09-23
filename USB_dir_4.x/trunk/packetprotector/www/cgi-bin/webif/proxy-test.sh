#!/usr/bin/webif-page
<? 
. /usr/lib/webif/webif.sh

header "Proxy" "AV Test" "@TR<<Web AV Test>>"

PROXY_ENABLED=`egrep "^dansguardian=" /etc/packetprotector.conf | cut -d "=" -f 2`

if [ "X$PROXY_ENABLED" = "X1" ] ; then
	echo 'AV test files from <a href=http://eicar.org>eicar.org</a>-<br /><br />'
	echo '<a href=http://www.eicar.org/download/eicar.com>eicar.com</a><br />'
	echo '<a href=http://www.eicar.org/download/eicar_com.zip>eicar_com.zip</a><br />'
	echo '<a href=http://www.eicar.org/download/eicarcom2.zip>eicarcom2.zip</a><br />'
	echo '<br />'
	echo "You will receive an 'access denied' message when trying to download these test virus files."

else
	echo 'DansGuardian is not enabled.  See the <a href=/cgi-bin/webif/proxy-settings.sh>Proxy Settings</a> page.'

fi

footer ?>
<!--
##WEBIF:name:Proxy:3:AV Test
-->
