#!/bin/sh

CONFIG_FILE="/etc/packetprotector.conf"
SNORT_INLINE=`grep "snort-inline=" $CONFIG_FILE | cut -d "=" -f 2`
if [ "X$SNORT_INLINE" = "X1" ] ; then
	iptables -F input_queue
	iptables -A input_queue -j QUEUE
	iptables -F output_queue
	iptables -A output_queue -j QUEUE
	iptables -F forwarding_queue
	iptables -A forwarding_queue -j QUEUE
else
	iptables -F input_queue
	iptables -A input_queue -j ACCEPT
	iptables -F output_queue
	iptables -A output_queue -j ACCEPT
	iptables -F forwarding_queue
	iptables -A forwarding_queue -j ACCEPT
fi
