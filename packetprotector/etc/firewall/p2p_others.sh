#!/bin/sh

if [ "X$1" = "Xblock" ] ; then
	#echo 'Blocking.'
	/usr/sbin/iptables -A forwarding_rule -p tcp -m layer7 --l7proto applejuice -j DROP
	/usr/sbin/iptables -A forwarding_rule -p tcp -m layer7 --l7proto ares -j DROP
	/usr/sbin/iptables -A forwarding_rule -p tcp -m layer7 --l7proto soulseek -j DROP

	
elif [ "X$1" = "Xunblock" ] ; then
	#echo 'Unblocking.'
	/usr/sbin/iptables -D forwarding_rule -p tcp -m layer7 --l7proto applejuice -j DROP
	/usr/sbin/iptables -D forwarding_rule -p tcp -m layer7 --l7proto ares -j DROP
	/usr/sbin/iptables -D forwarding_rule -p tcp -m layer7 --l7proto soulseek -j DROP
	
else
	echo 'Usage- '$0' block|unblock'
fi
