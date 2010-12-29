#!/bin/sh

CONFIG_FILE="/etc/packetprotector.conf"
SNORT_INLINE=`grep "snort-inline=" $CONFIG_FILE | cut -d "=" -f 2`
if [ "X$SNORT_INLINE" = "X1" ] ; then
	iptables -R FORWARD 2 -m state --state RELATED,ESTABLISHED -j ACCEPT
	iptables -R INPUT 1 -m state --state RELATED,ESTABLISHED -j ACCEPT
	iptables -R OUTPUT 1 -m state --state RELATED,ESTABLISHED -j ACCEPT	
fi
