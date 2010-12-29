#!/bin/sh

CONFIG_FILE="/etc/packetprotector.conf"
SNORT_INLINE=`grep "snort-inline=" $CONFIG_FILE | cut -d "=" -f 2`
WAN=`/sbin/uci get network.wan.ifname`
if [ "X$SNORT_INLINE" = "X1" ] ; then
	iptables -R FORWARD 2 -m state --state RELATED,ESTABLISHED -j QUEUE
	iptables -R zone_wan_ACCEPT 1 -o $WAN -j QUEUE
	iptables -R INPUT 1 -m state --state RELATED,ESTABLISHED -j QUEUE
fi
