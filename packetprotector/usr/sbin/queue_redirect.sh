#!/bin/sh

CONFIG_FILE="/etc/packetprotector.conf"
SNORT_INLINE=`grep "snort-inline=" $CONFIG_FILE | cut -d "=" -f 2`
WAN=`/sbin/uci get network.wan.ifname`

/bin/pidof snort-inline > /dev/null
if [ $? = 0 ] ; then

if [ "X$SNORT_INLINE" = "X1" ] ; then
	iptables -R FORWARD 2 -m state --state RELATED,ESTABLISHED -j QUEUE
	iptables -I zone_wan_ACCEPT 1 -o $WAN -j QUEUE
	iptables -R INPUT 1 -m state --state RELATED,ESTABLISHED -j QUEUE
fi

else
	echo "Snort-inline not running!"
fi