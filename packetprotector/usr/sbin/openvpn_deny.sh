#!/bin/sh

CONFIG_FILE="/etc/packetprotector.conf"
OPENVPN=`grep "openvpn=" $CONFIG_FILE | cut -d "=" -f 2`
LAN=`/sbin/uci get network.lan.ifname`
if [ "X$OPENVPN" = "X1" ] ; then
	iptables -D forward -i $LAN -o tun0 -j ACCEPT
	iptables -D forward -i tun0 -o $LAN -j ACCEPT
fi
