#!/usr/bin/webif-page

<html>

<head>
        <title>PacketProtector Admin Console</title>
	<link rel="stylesheet" type="text/css" href="/themes/active/webif.css">
	<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
</head>
<body>
<div id="container">
        <div id="header">
                <div id="header-title">
				<div id="openwrt-title"><h1>PacketProtector Admin Console</h1></div>
				<div id="short-status">
                                        <h3><strong>Status:</strong></h3>
                                        <ul>
                                                <li>*</li>
                                                <li>*</li>
                                                <li>*</li>
                                                <li>*</li>
                                        </ul>
                                </div>
		</div>
			<div id="mainmenu"><h3>VPN</h3></div>
			<div id="submenu"><ul><li><b>Remote Access</b></li></ul></div>

        </div>

        <div id="content">
			
<br /><br />
<? 

# 
# SUBROUTINES
#
instructions()
{
	echo "To setup access for a user other than '"$REMOTE_USER"'-<br /><br />"
	echo '<pre>'
	echo '	1) Verify the user exists on the <a href=/cgi-bin/webif/users.sh>Users</a> tab.'
	echo '	2) Logout (close your browser) and login as the appropriate user.'
	echo '	3) Return to the <a href=/cgi-bin/webif/vpn/VPNconnect.sh>VPN</a> page to create a certificate and private key for the new user.'
	echo '</pre>'
}

BASEDIR=/packetprotector
USER_KEY=$REMOTE_USER".key"
USER_CERT=$REMOTE_USER".crt"
USER_CSR=$REMOTE_USER".csr"
HOSTNAME=`hostname`
DYNAMIC_DNS=`uci get updatedd.cfg1.update 2> /dev/null`
if [ "X$DYNAMIC_DNS" = "X1" ] ; then
        ROUTER_ID=`uci get updatedd.cfg1.host`
else
        ROUTER_ID=`/sbin/ifconfig \`uci get network.wan.ifname\` | grep "inet addr" | cut -d":" -f2 | cut -d" " -f1`
fi

if [ "$FORM_passphrase" ] && [ "$FORM_confirm" ] ; then
	if [ "X$REMOTE_USER" = "Xserver" ] || [ "X$REMOTE_USER" = "Xradius" ] ; then
		echo 'Username '$REMOTE_USER' is not valid.  This certificate is used to identify the router.<br /><br />'
	elif [ "X$FORM_passphrase" = "X$FORM_confirm" ] ; then
	   if [ -s /etc/easy-rsa/keys/$REMOTE_USER.crt ] ; then
		echo 'Certificate and private key already exist for user '$REMOTE_USER'.<br /><br />'
	   else
		echo 'Passwords match.  Creating certificate and private key.<br /><br />'
		echo '<pre>'
		cd /etc/easy-rsa
		. ./vars > /dev/null
		# CREATE CUSTOM OPENSSL CONFIG FILE
		cat openssl.1 > openssl-client.cnf
		echo input_password = $FORM_passphrase >> openssl-client.cnf
		echo output_password = $FORM_passphrase >> openssl-client.cnf
		cat openssl.2 >> openssl-client.cnf
		echo commonName = $REMOTE_USER >> openssl-client.cnf
		cat openssl.3 >> openssl-client.cnf
		# GENERATE CLIENT KEY/CERT
		./build-key-pass-batch $REMOTE_USER > /dev/null
		rm openssl-client.cnf
		# MOVE FILES TO DOWNLOAD DIRECTORY
		mkdir /www/$REMOTE_USER
		cd /www/$REMOTE_USER
		egrep "^root:|^$REMOTE_USER:" /www/cgi-bin/webif/vpn/.htpasswd > .htpasswd
		chmod 600 .htpasswd
		ln -s /etc/easy-rsa/keys/ca.crt /www/$REMOTE_USER/ca.crt
		ln -s /etc/easy-rsa/keys/$USER_KEY /www/$REMOTE_USER/$USER_KEY
		ln -s /etc/easy-rsa/keys/$USER_CERT /www/$REMOTE_USER/$USER_CERT
		cp $BASEDIR/etc/openvpn/client.ovpn /www/$REMOTE_USER/$HOSTNAME.ovpn
		echo "cert $USER_CERT" >> $HOSTNAME.ovpn
		echo "key $USER_KEY" >> $HOSTNAME.ovpn
		sed -i "s/^remote .*$/remote $ROUTER_ID 1194/" $HOSTNAME.ovpn
		unix2dos $HOSTNAME.ovpn
		echo '</pre>'
		echo '<br />Completed.<br /><br />'
	   fi
	else
		echo 'Passwords do not match.  Please try again.<br />'
	fi
echo ''
fi
	
cd /etc/easy-rsa/keys
OPENVPN_ENABLED=`egrep "^openvpn=" /etc/packetprotector.conf | cut -d "=" -f 2`
if ([ -s "dh1024.pem" ] && [ "X$OPENVPN_ENABLED" = "X1" ]) ; then
	#echo 'CA properly configured.'
	#echo $USER_KEY $USER_CERT
	if ([ -s $USER_CERT ] && [ -s $USER_KEY ]); then
		echo 'Windows users download the OpenVPN client here (props to <a href=http://www.openvpn.se>Mathias Sundman</a>)-'
		echo '<br /><br />'
		echo '<a href=http://openvpn.se/>OpenVPN GUI for Windows</a>'
		echo '<br /><br />'
		echo 'OS X, Linux, and BSD users download OpenVPN here (props to the <a href=http://openvpn.net>OpenVPN</a> team)-'
		echo '<br /><br />'
		echo '<a href=http://openvpn.net/download.html>OpenVPN source tarball</a>'
		echo '<br /><br />'
		#echo $REMOTE_USER 'cert found!'
		# DISPLAY KEY AND CERT DOWNLOAD
		echo 'After installing the OpenVPN software on the client, download the following'
		echo "four files to OpenVPN's config directory (C:\Program Files\OpenVPN\config for Windows)-"
		echo '<br /><br />'
		echo '<table CELLSPACING="5">'
		echo '<tr>'
		echo '<td width=200><a href=/'$REMOTE_USER'/'$HOSTNAME'.ovpn>'$HOSTNAME'.ovpn</a><br />'
		echo '<td>OpenVPN client config file'
		echo '</tr>'
		echo '<tr>'
		echo '<td width=200><a href=/'$REMOTE_USER'/ca.crt>ca.crt</a><br />'
		echo '<td>CA public key'
		echo '</tr>'
		echo '<tr>'
		echo '<td width=200><a href=/'$REMOTE_USER'/'$USER_CERT'>'$USER_CERT'</a><br />'
		echo '<td>your public key'
		echo '</tr>'
		echo '<tr>'
		echo '<td width=200><a href=/'$REMOTE_USER'/'$USER_KEY'>'$USER_KEY'</a>'
		echo '<td>your private key (note: this file should only be transmitted over a secure channel (e.g. SSL or SCP))'
		echo '</tr>'
		echo '</table>'
		echo '<br />'
		
		if [ "X$REMOTE_USER" = "Xroot" ]; then
			echo "The root user can download other users' certificates and config files from-"
			echo '<br /><br />'
			echo '<pre>	https://local.packetprotector.org/$USERNAME/</pre>'
			echo '<br /><br />'
		fi
		#instructions
	else
		echo "No certificate found for user '"$REMOTE_USER"'.<br />"
		echo '<br />'
		echo 'You must create a certificate and private key before connecting via the VPN.<br />'
		echo "Please enter the passphrase you'd like to use for your private key." 
		echo '<br /><br />'
		echo '<table>'
		echo '<form enctype="multipart/form-data" method="post">'
		echo '<tr>'
		echo '<td>Passphrase:'
		echo '<td><input type="password" name="passphrase" value="">'
                echo '</tr>'
                echo '<td>Confirm:'
                echo '<td><input type="password" name="confirm" value="">'
                echo '<td><input type="submit" name="create" value="Create cert!">'
                echo '</tr>'
                echo '</table>'
                echo '</form>'
		echo '<br />'
		#instructions
	fi
else
	echo "The VPN setup isn't complete.  Please check the <a href=/cgi-bin/webif/VPNsettings.sh>VPN settings</a> page.  Note- requires root access.<br />"
fi

#echo $REMOTE_ADDR
#echo $REMOTE_USER

?>

        </div>
</div>
</body>

</html>
