#!/bin/sh

if [ "X$1" = "Xblock" ] ; then
	#echo 'Blocking.'
	echo '127.0.0.2 scs.msg.yahoo.com' >> /etc/hosts
	echo '127.0.0.2 scsa.msg.yahoo.com' >> /etc/hosts
	echo '127.0.0.2 scsb.msg.yahoo.com' >> /etc/hosts
	echo '127.0.0.2 scsc.msg.yahoo.com' >> /etc/hosts
	echo '127.0.0.2 scsd.msg.yahoo.com' >> /etc/hosts
	echo '127.0.0.2 scse.msg.yahoo.com' >> /etc/hosts
	echo '127.0.0.2 scsf.msg.yahoo.com' >> /etc/hosts
	/usr/bin/killall -HUP dnsmasq
	
elif [ "X$1" = "Xunblock" ] ; then
	#echo 'Unblocking.'
	/bin/sed -i "/^127.0.0.2 scs.msg.yahoo.com/d" /etc/hosts
	/bin/sed -i "/^127.0.0.2 scsa.msg.yahoo.com/d" /etc/hosts
	/bin/sed -i "/^127.0.0.2 scsb.msg.yahoo.com/d" /etc/hosts
	/bin/sed -i "/^127.0.0.2 scsc.msg.yahoo.com/d" /etc/hosts
	/bin/sed -i "/^127.0.0.2 scsd.msg.yahoo.com/d" /etc/hosts
	/bin/sed -i "/^127.0.0.2 scse.msg.yahoo.com/d" /etc/hosts
	/bin/sed -i "/^127.0.0.2 scsf.msg.yahoo.com/d" /etc/hosts
	/usr/bin/killall -HUP dnsmasq
	
else
	echo 'Usage- '$0' block|unblock'
fi
