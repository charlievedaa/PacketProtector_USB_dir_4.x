#!/bin/sh

if [ "X$1" = "Xblock" ] ; then
	#echo 'Blocking.'
	/usr/sbin/iptables -D input_rule -p tcp --dport 22 -j ACCEPT
	
elif [ "X$1" = "Xunblock" ] ; then
	#echo 'Unblocking.'
	/usr/sbin/iptables -A input_rule -p tcp --dport 22 -j ACCEPT
	
else
	echo 'Usage- '$0' block|unblock'
fi
