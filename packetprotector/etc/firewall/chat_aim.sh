#!/bin/sh

if [ "X$1" = "Xblock" ] ; then
	#echo 'Blocking.'
	echo '127.0.0.2 ats.byoa.aol.com' >> /etc/hosts
	echo '127.0.0.2 login.oscar.aol.com' >> /etc/hosts
	/usr/bin/killall -HUP dnsmasq
	
elif [ "X$1" = "Xunblock" ] ; then
	#echo 'Unblocking.'
	/bin/sed -i "/^127.0.0.2 ats.byoa.aol.com/d" /etc/hosts
	/bin/sed -i "/^127.0.0.2 login.oscar.aol.com/d" /etc/hosts
	/usr/bin/killall -HUP dnsmasq
	
else
	echo 'Usage- '$0' block|unblock'
fi
