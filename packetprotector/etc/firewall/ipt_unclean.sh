#!/bin/sh

if [ "X$1" = "Xblock" ] ; then
	#echo 'Blocking.'
	insmod ipt_unclean 2> /dev/null > /dev/null
	/usr/sbin/iptables -I forwarding_rule 1 -m unclean -j DROP
	
elif [ "X$1" = "Xunblock" ] ; then
	#echo 'Unblocking.'
	/usr/sbin/iptables -D forwarding_rule -m unclean -j DROP
	
else
	echo 'Usage- '$0' block|unblock'
fi
