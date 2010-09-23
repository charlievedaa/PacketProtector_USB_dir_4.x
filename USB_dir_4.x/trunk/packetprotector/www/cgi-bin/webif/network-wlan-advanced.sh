#!/usr/bin/webif-page
<? 
. /usr/lib/webif/webif.sh

header "Network" "Advanced WLAN" "@TR<<Advanced WLAN Configuration>>"

if [ "$FORM_txpower" ] ; then
	uci set wireless.wl0.txpower=$FORM_txpower
	uci commit
	wl txpwr1 $FORM_txpower
fi

TXPOWER=`uci -q get wireless.wl0.txpower`

echo '<form enctype="multipart/form-data" method="post">'
echo 'iwconfig wl0-<br/><br/>'
echo '<pre>'
iwconfig wl0
echo '</pre>'
echo 'wl txpwr1-<br/><br/>'
echo '<pre>'
wl txpwr1
echo '</pre>'
echo '<br/>'
echo 'Set transmit power (in dBm)-<br/>'
echo '<input type="text" size="5" name="txpower" value="'$TXPOWER'">'
echo '<input type="submit" name="submit_txpower" value="Submit">'
echo '</form>'
echo '<br />'


footer ?>
<!--
##WEBIF:name:Network:350:Advanced WLAN
-->
