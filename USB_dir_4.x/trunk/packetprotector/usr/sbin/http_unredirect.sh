#!/bin/sh

IPADDR=`uci get network.lan.ipaddr`

iptables -t nat -D prerouting_rule -i br-lan -p tcp --dport 80 -j DNAT --to $IPADDR
