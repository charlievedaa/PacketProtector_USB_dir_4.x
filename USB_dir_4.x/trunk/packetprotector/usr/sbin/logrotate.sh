#!/bin/sh

cd /packetprotector/logs
for i in `ls *.log`; do
	cp $i $i.OLD
	cat /dev/null > $i
done
