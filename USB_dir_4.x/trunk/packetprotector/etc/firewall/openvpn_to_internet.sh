#!/bin/sh

WAN=`uci get network.wan.ifname`
SNORT_INLINE=`grep "snort-inline=" /etc/packetprotector.conf | cut -d "=" -f 2`

if [ "X$1" = "Xblock" ] ; then
	#echo 'Blocking.'
	if [ "X$SNORT_INLINE" = "X0" ] ; then
		/usr/sbin/iptables -D FORWARD -i tun0 -o $WAN -j ACCEPT
	else
		/usr/sbin/iptables -D FORWARD -i tun0 -o $WAN -j QUEUE
	fi
	
elif [ "X$1" = "Xunblock" ] ; then
	#echo 'Unblocking.'
	if [ "X$SNORT_INLINE" = "X0" ] ; then
		/usr/sbin/iptables -A FORWARD -i tun0 -o $WAN -j ACCEPT
	else
		/usr/sbin/iptables -A FORWARD -i tun0 -o $WAN -j QUEUE
	fi
	
else
	echo 'Usage- '$0' block|unblock'
fi
