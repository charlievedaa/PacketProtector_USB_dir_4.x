#!/bin/sh

LAN=`/sbin/uci get network.lan.ifname`

	iptables -D forward -i $LAN -o tun0 -j ACCEPT
	iptables -D forward -i tun0 -o $LAN -j ACCEPT
