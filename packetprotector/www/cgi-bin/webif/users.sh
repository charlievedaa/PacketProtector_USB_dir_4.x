#!/usr/bin/webif-page
<? 
. /usr/lib/webif/webif.sh

header "Users" "Accounts" "@TR<<Accounts>>"

# CREATE NEW USER
if [ "$FORM_username" ] && [ "$FORM_password" ] && [ "$FORM_confirm" ] ; then
   if [ "X$FORM_password" = "X$FORM_confirm" ] ; then
	EXISTING_USER=0
	for i in `cut -d: -f1 /etc/passwd`; do
		if [ "X$i" = "X$FORM_username" ] ; then
			EXISTING_USER=1
		fi  	
	done
	if [ "$EXISTING_USER" = 1 ] ; then
		echo 'User already exists!<br /><br />'
	else
		if [ "X$FORM_username" = "Xserver" ] || [ "X$FORM_username" = "Xradius" ] || [ "X$FORM_username" = "Xbackup" ] || [ "X$FORM_username" = "Xcgi-bin" ] || [ "X$FORM_username" = "Xerrors" ] ; then
			echo "Username '$FORM_username' reserved for system use.<br /><br />"
		else
			if [ "X$FORM_shell" = "X1" ] ; then
				(echo $FORM_password; sleep 1; echo $FORM_password) | adduser -h /home/$FORM_username -s /bin/ash $FORM_username > /dev/null || echo 'Error creating user.<br />'
				cp /packetprotector/etc/skel/.profile /home/$FORM_username/.profile
				chown $FORM_username:$FORM_username /home/$FORM_username/.profile 
				chmod 644 /home/$FORM_username/.profile
			else
				(echo $FORM_password; sleep 1; echo $FORM_password) | adduser -Hh /tmp -s /bin/false $FORM_username > /dev/null || echo 'Error creating user.<br />'
			fi
			echo '"'$FORM_username'"		Cleartext-Password := "'$FORM_password'"' >> /etc/freeradius/users || echo 'Error creating RADIUS user.<br />'
			grep '^'$FORM_username':' /etc/shadow | cut -d: -f1,2 >> /www/cgi-bin/webif/vpn/.htpasswd
		
			echo 'Completed!<br /><br />'			
		fi
	fi 
   else
	echo 'Passwords do not match.  Please try again.<br />'
   fi
fi

#UPDATE OR DELETE USER
for uid in `cut -d: -f3 /etc/passwd | egrep -v "^65534$`; do 
	FORM_delete_user="FORM_delete_$uid"
	eval "FORM_delete_user_VALUE=\$$FORM_delete_user"

	FORM_change_user="FORM_change_$uid"
	eval "FORM_change_user_VALUE=\$$FORM_change_user"

        FORM_confirm_user="FORM_confirm_$uid"
        eval "FORM_confirm_user_VALUE=\$$FORM_confirm_user"
        
        #switch from UID to username
        user=`grep ":$uid:" /etc/passwd | cut -d: -f1`

	if [ "$FORM_delete_user_VALUE" = 1 ] ; then
	   if [ "X$user" = "X0" ] ; then
		echo 'Cannot delete user 'root'!<br />'
	   else
		deluser $user 2> /dev/null
		delgroup $user 2> /dev/null
		sed -i "s/^\"$user\".*$//" /etc/freeradius/users
		sed -i "s/^$user:.*$//" /www/cgi-bin/webif/vpn/.htpasswd
		if [ -d /www/$user ] ; then
			rm -rf /www/$user
			cd /etc/easy-rsa
			. ./vars > /dev/null
			./revoke-full $user > /dev/null
			rm -f /etc/easy-rsa/keys/$user.crt
			rm -f /etc/easy-rsa/keys/$user.csr
			rm -f /etc/easy-rsa/keys/$user.key
			rm -f `grep -l CN=$user\/ /etc/easy-rsa/keys/*.pem`
		fi
		echo "User '$user' deleted!<br />"
	   fi
	fi

	if [ ${#FORM_change_user_VALUE} -gt 0 ] ; then
		if [ "$FORM_change_user_VALUE" = "$FORM_confirm_user_VALUE" ] ; then
			
			# update /etc/shadow and /etc/freeradius/users

			(echo $FORM_change_user_VALUE; sleep 1; echo $FORM_change_user_VALUE) | passwd $user > /dev/null
			sed -i "s/\"$user\".*/\"$user\"		Cleartext-Password := \"$FORM_change_user_VALUE\"/" /etc/freeradius/users

			# update .htpasswd in the VPN download directory

			if [ -s /www/$user/.htpasswd ] ; then
				sed -i "s/^$user:.*$//" /www/$user/.htpasswd
				grep '^'$user':' /etc/shadow | cut -d: -f1,2 >> /www/$user/.htpasswd
				
			fi

                        # update .htpasswd in the VPN directory

                        if [ -s /www/cgi-bin/webif/vpn/.htpasswd ] ; then
				sed -i "s/^$user:.*$//" /www/cgi-bin/webif/vpn/.htpasswd
				grep '^'$user':' /etc/shadow | cut -d: -f1,2 >> /www/cgi-bin/webif/vpn/.htpasswd
			fi

			# update /www/cgi-bin/webif/.htpasswd (root only)

			if [ "$user" = "root" ] ; then
				sed -i "s/^$user:.*$//" /www/cgi-bin/webif/.htpasswd
				grep '^'$user':' /etc/shadow | cut -d: -f1,2 >> /www/cgi-bin/webif/.htpasswd
			fi
			
			echo 'Password updated!<br />'

		else
			echo 'Passwords do not match.  Please try again.<br />'
		fi
	fi

done
echo '<br />'

echo '<table>'
echo '<tr><td width=200>Existing users-'
echo '<form enctype="multipart/form-data" method="post">'
echo '<td>new password'
echo '<td>confirm'
echo '<td>&nbsp'
echo '</tr>'
echo '<tr><td width=200><b>root</b>'
echo '<td><input type="password" name="change_0" value="">'
echo '<td><input type="password" name="confirm_0" value="">' 
echo '<td>&nbsp'
echo '</tr>'

for i in `cut -d: -f1,3 /etc/passwd | egrep -v "^root:0$|^nobody:65534$"`; do
	user=`echo $i | cut -d: -f1`
	uid=`echo $i | cut -d: -f2`
	echo '<tr><td width=200><b>'$user'</b>'
	echo '<td><input type="password" name="change_'$uid'" value="">'
	echo '<td><input type="password" name="confirm_'$uid'" value="">'
	echo '<td><input type="checkbox" name="delete_'$uid'" value="1"> Delete?'
	echo '</tr>'
done

echo '</table>'
echo '<br />'
echo '<input type="submit" name="add" value="Update!">'
echo '</form>'
echo '<br /><br />'

echo 'Create new user-<br /><br />'
echo '<form enctype="multipart/form-data" method="post">'
echo '<table>'
echo '<tr><td width=200>Username: <td><input type="text" name="username" value=""></tr>'
echo '<tr><td width=200>Password: <td><input type="password" name="password" value=""><br /></tr>'
echo '<tr><td width=200>Confirm: <td><input type="password" name="confirm" value=""><br /></tr>'
echo '<tr><td width=200>Shell access: <td><input type="radio" name="shell" value="0" checked>disabled <input type="radio" name="shell" value="1"> enabled<br /></tr>'
echo '</table>'
echo '<br />'
echo '<td><input type="submit" name="add" value="Add user!">'
echo '</form>'
echo '<br />'


footer ?>
<!--
##WEBIF:name:Users:1:Accounts
-->
