#!/bin/sh

CONFIG_FILE="/etc/packetprotector.conf"
OPENVPN=`grep "openvpn=" $CONFIG_FILE | cut -d "=" -f 2`
LAN=`/sbin/uci get network.lan.ifname`

/bin/pidof openvpn
if [ $? = 0 ] ; then

if [ "X$OPENVPN" = "X1" ] ; then
	iptables -I forward 1 -i $LAN -o tun0 -j ACCEPT
	iptables -I forward 2 -i tun0 -o $LAN -j ACCEPT
fi

else
	echo "OpenVPN not running!"
fi
