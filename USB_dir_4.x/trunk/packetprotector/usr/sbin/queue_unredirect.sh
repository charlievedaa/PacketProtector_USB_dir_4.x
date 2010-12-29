#!/bin/sh

WAN=`/sbin/uci get network.wan.ifname`

	iptables -R FORWARD 2 -m state --state RELATED,ESTABLISHED -j ACCEPT
	iptables -R zone_wan_ACCEPT 1 -o $WAN -j ACCEPT
	iptables -R INPUT 1 -m state --state RELATED,ESTABLISHED -j ACCEPT
