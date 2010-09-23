#!/bin/sh

WAN=`uci get network.wan.ifname`

if [ "X$1" = "Xblock" ] ; then
	#echo 'Blocking.'
	/usr/sbin/iptables -I forwarding_rule 1 -o $WAN -p udp --dport 53 -j DROP
	
elif [ "X$1" = "Xunblock" ] ; then
	#echo 'Unblocking.'
	/usr/sbin/iptables -D forwarding_rule -o $WAN -p udp --dport 53 -j DROP
	
else
	echo 'Usage- '$0' block|unblock'
fi
