#!/usr/bin/webif-page
<? 
. /usr/lib/webif/webif.sh

header "CA" "Settings" "@TR<<Certificate Authority>>"

BASEDIR="/packetprotector"
DH_RUNNING=`ps | grep "openssl dhparam" | grep -v grep`

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

cd /etc/easy-rsa/keys
if [ -s "dh1024.pem" ] ; then
	echo 'The local CA is initialized.<br /><br />'
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

echo 'Download the root certificate-<br /><br />'
echo '<a href=/ca.crt>ca.crt</a><br /><br />'
echo 'Note- you may need to install this certificate on your workstation to configure server validation for Protected EAP (PEAP) authentication (WPA/WPA2 Enterprise only).<br /><br />'

#echo $REMOTE_ADDR 
#echo $REMOTE_USER

# Display current CA's basic info
openssl x509 -in /etc/easy-rsa/keys/ca.crt -noout -text | grep Issuer:
echo '<br />''<br />'
openssl x509 -in /etc/easy-rsa/keys/ca.crt -noout -text | grep Validity
echo '<br />'
openssl x509 -in /etc/easy-rsa/keys/ca.crt -noout -text | grep "Not Before:"
echo '<br />'
openssl x509 -in /etc/easy-rsa/keys/ca.crt -noout -text | grep "Not After :"

footer ?>
<!--
##WEBIF:name:CA:1:Settings
-->
