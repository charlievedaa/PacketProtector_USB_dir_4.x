#!/bin/sh

IPADDR=`uci get network.lan.ipaddr`

/bin/pidof dansguardian > /dev/null
if [ $? = 0 ] ; then
	iptables -t nat -A prerouting_rule -i br-lan -p tcp --dport 80 -j DNAT --to $IPADDR
else
	echo "DansGuardian not running!"
fi
