#!/usr/bin/webif-page
<? 
. /usr/lib/webif/webif.sh

header "CA" "Recreate" "@TR<<Recreate Certificate Authority>>"

BASEDIR="/packetprotector"

if [ $FORM_initialize ] ; then
	DH_RUNNING=`ps | grep "openssl dhparam" | grep -v grep`
	echo '<pre>'
	cd /etc/easy-rsa/keys
	if [ -n "$DH_RUNNING" ] ; then
		echo 'Diffie Hellman parameters are currently being generated.'
		echo ''
		echo '$DH_RUNNING'
		echo ''
		echo 'Please check back in 15-30 minutes.'
		echo '' 
	else
		# Backup keys and certs
		cd /etc/easy-rsa
		# load current variables (start with KEY_)
		. ./vars
		d=$KEY_DIR
		if [ ! -e $BASEDIR/bkup-keys ] ; then
			mkdir $BASEDIR/bkup-keys
		fi
		cp -pf $d/* $BASEDIR/bkup-keys/ > /dev/null 2> /dev/null
		cp -pf $d/.* $BASEDIR/bkup-keys/ > /dev/null 2> /dev/null
		cp -pf /etc/mini_httpd/server.pem /etc/mini_httpd/bkup-server.pem > /dev/null 2> /dev/null
		for i in `grep $DEFAULT_DAYS * | cut -d: -f1` ; do
			cp -pf $i $BASEDIR/bkup-keys/ > /dev/null 2> /dev/null
		done
		cp -pf vars $BASEDIR/bkup-keys/ > /dev/null 2> /dev/null
		cp -pf openssl.3 $BASEDIR/bkup-keys/ > /dev/null 2> /dev/null
		for i in `grep "countryName.*\= [A-Z][A-Z]" * | cut -d: -f1` ; do
			cp -pf $i $BASEDIR/bkup-keys/ > /dev/null 2> /dev/null
		done
		# End backup

	if [ "X$FORM_COUNTRY" ] && [ "X$FORM_PROVINCE" ] && [ "X$FORM_CITY" ] && [ "X$FORM_ORG" ] && [ "X$FORM_EMAIL" ] && [ "X$FORM_NEW_DAYS" ]; then
		# Set the new variables, take these from the web ui
		COUNTRY="$FORM_COUNTRY"		#Two Letter code
		PROVINCE="$FORM_PROVINCE"	#Two Letter code
		CITY="$FORM_CITY"
		ORG="$FORM_ORG"
		EMAIL="$FORM_EMAIL"
		# Number of days for certificate expiration
		# the default from Packetprotector is 3650
		DEFAULT_DAYS=3650
		NEW_DAYS="$FORM_NEW_DAYS"
	else	
		# Defaults Section to change the CA info (ie. Charlie and Packetprotector.org, etc.)
		# to your own personal info.
		COUNTRY=US	#Two Letter code
		PROVINCE=MD	#Two Letter code
		CITY=Gaithersburg
		ORG=PacketProtector.org
		EMAIL=charlie@packetprotector.org
		# Number of days for certificate expiration
		# the default from Packetprotector is 3650
		# Change the NEW_DAYS variable to what you want
		DEFAULT_DAYS=3650
		NEW_DAYS=7300
	fi

		# Get files with number of Days, replace defaults with new variables.
		for i in `grep "\days.*" * | cut -d: -f1` ; do
       			DEFAULT_DAYS=`grep "\-days.*" $i | awk '{FS="-days"; print $2}' | cut -d" " -f2 | uniq`
       			sed -i "s/$DEFAULT_DAYS/$NEW_DAYS/" $i > /dev/null 2>/dev/null
       			sed -i -r "s/default_days.*\= .*/default_days\t\= $NEW_DAYS/" $i
		done

		# Edit the vars file
		sed -i "s/KEY_COUNTRY=$KEY_COUNTRY/KEY_COUNTRY=$COUNTRY/" ./vars
		sed -i "s/KEY_PROVINCE=$KEY_PROVINCE/KEY_PROVINCE=$PROVINCE/" ./vars
		sed -i -r "s/[\"]?$KEY_CITY[\"]?/\"$CITY\"/" ./vars
		sed -i "s/"$KEY_ORG"/"$ORG"/" ./vars
		sed -i "s/"$KEY_EMAIL"/"$EMAIL"/" ./vars
		
		#  Edit the one file that doesnt have countryName (openssl.3),
		#  then Use the countryName filelist and change everything else
		sed -i "s/$KEY_EMAIL/$EMAIL/" ./openssl.3

		# Get files with countryName, replace defaults with new variables.
		for i in `grep "countryName.*\= [A-Z][A-Z]" * | cut -d: -f1` ; do
			sed -i "s/countryName.*\= $KEY_COUNTRY/countryName\t\= $COUNTRY/" $i
			sed -i "s/stateOrProvinceName.*\= $KEY_PROVINCE/stateOrProvinceName\t\= $PROVINCE/" $i
			sed -i -r "s/[\"]?$KEY_CITY[\"]?/\"$CITY\"/" $i
			sed -i "s/$KEY_ORG/$ORG/" $i
			sed -i "s/$KEY_EMAIL/$EMAIL/" $i
			# want to get $ORG to lowercase
			LOWERCASE_ORG=`echo "$FORM_$ORG" | tr '[A-Z]' '[a-z]'`
			sed -i "s/commonName.*\= local.*/commonName\t\= local.$LOWERCASE_ORG/" $i
			sed -i "s/commonName.*\= radius.*/commonName\t\= radius.$LOWERCASE_ORG/" $i
		done

		# Start recreating
		. ./vars > /dev/null
		./clean-all
		echo $(($RANDOM % 89 + 10)) > keys/serial
		./build-ca-batch
		./build-key-server-batch server
		./build-key-radius-batch radius
		. ./vars > /dev/null
		cp openssl-revoked.cnf openssl-client.cnf
		./build-key-pass-batch examplerevokedcert
		rm openssl-client.cnf
		./revoke-full examplerevokedcert
		echo 'Generating Diffie Hellman parameters.'
		echo ''
		echo 'GET COMFORTABLE, THIS MAY TAKE 15-30 MINUTES!'
		echo ''
		. ./vars > /dev/null
		./build-dh
		cat $d/server.crt $d/server.key > /etc/mini_httpd/server.pem
		echo 'Completed creating CA and Server certificates.'
		echo 'To complete certificate creation, please visit the VPN tab to recreate the roots certificate.'
		echo ''
	fi
	echo '</pre>'
fi		

cd /etc/easy-rsa/keys
if [ -s "dh1024.pem" ] ; then
	echo '******************WARNING**********************<br /><br />'
	echo 'The local CA is already initialized.<br /><br />'
	echo '******************WARNING**********************<br /><br />'
elif [ -n "$DH_RUNNING" ] ; then
        echo 'Diffie Hellman parameters are currently being generated.<br />'
        echo '<pre>$DH_RUNNING</pre><br />'
        echo 'Please check back in 15-30 minutes.<br />'
else
	echo 'CA is not initialized.<br /><br />'
	echo '<form enctype="multipart/form-data" method="post">'
	echo 'Click <input type="submit" name="initialize" value="initialize"> to enable the local certificate authority.<br /><br />'
	echo 'WARNING- it may take 15-30 minutes to generate the Diffie Hellman parameters!<br /><br />'
fi

echo '<form enctype="multipart/form-data" method="post">'
echo '<table>'
echo '<tr><td colspan=2>Enter your information for CA variables: </tr>'
echo '<tr><td>Number of Days for CA expiration <td> <input type="text" size="5" name="NEW_DAYS" value="'$NEW_DAYS'"></tr>'
echo '<tr><td>Two-Letter Country Code <td> <input type="text" size="5" name="COUNTRY" value="'$COUNTRY'"></tr>'
echo '<tr><td>Two-Letter State or Province Code <td> <input type="text" size="5" name="PROVINCE" value="'$PROVINCE'"></tr>'
echo '<tr><td>City <td> <input type="text" size="35" name="CITY" value="'$CITY'"></tr>'
echo '<tr><td>Organization <td> <input type="text" size="35" name="ORG" value="'$ORG'"></tr>'
echo '<tr><td>Administrator email address <td> <input type="text" size="35" name="EMAIL" value="'$EMAIL'"></tr>'
#echo '<tr><td>Number of Days for CA expiration <td> <input type="text" size="5" name="NEW_DAYS" value=""></tr>'
#echo '<tr><td>Two-Letter Country Code <td> <input type="text" size="5" name="COUNTRY" value=""></tr>'
#echo '<tr><td>Two-Letter State or Province Code <td> <input type="text" size="5" name="PROVINCE" value=""></tr>'
#echo '<tr><td>City <td> <input type="text" size="35" name="CITY" value=""></tr>'
#echo '<tr><td>Organization <td> <input type="text" size="35" name="ORG" value=""></tr>'
#echo '<tr><td>Administrator email address <td> <input type="text" size="35" name="EMAIL" value=""></tr>'
echo '</form>'
echo '</table>'
echo '<br />'

echo 'Click the button ONLY if you want to recreate the local CA<br /><br />'
echo 'Click <input type="submit" name="initialize" value="initialize"> to re-create the local certificate authority.<br /><br />'
echo 'WARNING- it may take 15-30 minutes to generate the Diffie Hellman parameters!<br /><br />'

footer ?>
<!--
##WEBIF:name:CA:2:Recreate
-->
