#!/bin/sh

export LD_LIBRARY_PATH=/packetprotector/usr/lib

if [ "X$1" = "Xblock" ] ; then
	#echo 'Blocking.'
	/bin/sed -i "s/^#include \$RULE_PATH\/bittorrent.rules/include \$RULE_PATH\/bittorrent.rules/" /packetprotector/etc/snort/snort-inline.conf
	echo "Snort-inline must to be restarted to enable BitTorrent blocking."
	
elif [ "X$1" = "Xunblock" ] ; then
	#echo 'Unblocking.'
	/bin/sed -i "s/^include \$RULE_PATH\/bittorrent.rules/#include \$RULE_PATH\/bittorrent.rules/" /packetprotector/etc/snort/snort-inline.conf
	echo "Snort-inline must to be restarted to disable BitTorrent blocking."
	
else
	echo 'Usage- '$0' block|unblock'
fi
