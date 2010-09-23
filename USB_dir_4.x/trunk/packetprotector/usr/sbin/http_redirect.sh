#!/bin/sh

IPADDR=`uci get network.lan.ipaddr`

/packetprotector/usr/sbin/lsof -n -i tcp:80 | grep dansguard > /dev/null
if [ $? = 0 ] ; then
	iptables -t nat -A prerouting_rule -i br-lan -p tcp --dport 80 -j DNAT --to $IPADDR
else
	echo "DansGuardian not running!"
fi
