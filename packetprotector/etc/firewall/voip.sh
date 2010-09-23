#!/bin/sh

WAN=`uci get network.wan.ifname`

if [ "X$1" = "Xblock" ] ; then
	#echo 'Blocking.'
	#DNS accept is workaround for bug reported here-
	#https://packetprotector.org/forum/viewtopic.php?id=4246
	/usr/sbin/iptables -A forwarding_rule -o $WAN -p udp --dport 53 -j ACCEPT
	/usr/sbin/iptables -A forwarding_rule -o $WAN -m layer7 --l7proto h323 -j DROP
	/usr/sbin/iptables -A forwarding_rule -o $WAN -m layer7 --l7proto sip -j DROP
	/usr/sbin/iptables -A forwarding_rule -o $WAN -m layer7 --l7proto skypeout -j DROP
	/usr/sbin/iptables -A forwarding_rule -o $WAN -m layer7 --l7proto skypetoskype -j DROP
	/usr/sbin/iptables -A forwarding_rule -o $WAN -m layer7 --l7proto teamspeak -j DROP
	
elif [ "X$1" = "Xunblock" ] ; then
	#echo 'Unblocking.'
	/usr/sbin/iptables -D forwarding_rule -o $WAN -p udp --dport 53 -j ACCEPT
	/usr/sbin/iptables -D forwarding_rule -o $WAN -m layer7 --l7proto h323 -j DROP
	/usr/sbin/iptables -D forwarding_rule -o $WAN -m layer7 --l7proto sip -j DROP
	/usr/sbin/iptables -D forwarding_rule -o $WAN -m layer7 --l7proto skypeout -j DROP
	/usr/sbin/iptables -D forwarding_rule -o $WAN -m layer7 --l7proto skypetoskype -j DROP
	/usr/sbin/iptables -D forwarding_rule -o $WAN -m layer7 --l7proto teamspeak -j DROP
	
else
	echo 'Usage- '$0' block|unblock'
fi
