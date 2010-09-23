#!/bin/sh

if [ "X$1" = "Xblock" ] ; then
	#echo 'Blocking.'
	echo '127.0.0.2 messenger.hotmail.com' >> /etc/hosts
	echo '127.0.0.2 webmessenger.msn.com' >> /etc/hosts
	echo '127.0.0.2 login.live.com' >> /etc/hosts
	/usr/bin/killall -HUP dnsmasq
	
elif [ "X$1" = "Xunblock" ] ; then
	#echo 'Unblocking.'
	/bin/sed -i "/^127.0.0.2 messenger.hotmail.com/d" /etc/hosts
	/bin/sed -i "/^127.0.0.2 webmessenger.msn.com/d" /etc/hosts
	/bin/sed -i "/^127.0.0.2 login.live.com/d" /etc/hosts
	/usr/bin/killall -HUP dnsmasq
	
else
	echo 'Usage- '$0' block|unblock'
fi
