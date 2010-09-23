#!/bin/sh

if [ "X$1" = "Xblock" ] ; then
	#echo 'Blocking.'
	/usr/sbin/iptables -A forwarding_rule -p tcp -m layer7 --l7proto fasttrack -j DROP
	/usr/sbin/iptables -A forwarding_rule -p udp -m layer7 --l7proto fasttrack -j DROP
	
elif [ "X$1" = "Xunblock" ] ; then
	#echo 'Unblocking.'
	/usr/sbin/iptables -D forwarding_rule -p tcp -m layer7 --l7proto fasttrack -j DROP
	/usr/sbin/iptables -D forwarding_rule -p udp -m layer7 --l7proto fasttrack -j DROP
	
else
	echo 'Usage- '$0' block|unblock'
fi
