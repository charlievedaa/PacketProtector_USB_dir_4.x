#!/bin/sh

WAN=`uci get network.wan.ifname`

if [ "X$1" = "Xblock" ] ; then
	#echo 'Blocking.'
	/usr/sbin/iptables -A forwarding_rule -o $WAN -m multiport -p tcp --dports 6665,6666,6667,6668,6669 -j REJECT --reject-with tcp-reset
	
elif [ "X$1" = "Xunblock" ] ; then
	#echo 'Unblocking.'
	/usr/sbin/iptables -D forwarding_rule -o $WAN -m multiport -p tcp --dports 6665,6666,6667,6668,6669 -j REJECT --reject-with tcp-reset
	
else
	echo 'Usage- '$0' block|unblock'
fi
