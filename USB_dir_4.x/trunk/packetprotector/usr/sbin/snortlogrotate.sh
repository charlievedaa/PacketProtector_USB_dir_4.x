#!/bin/sh

SNORT_INLINE_ENABLED=`egrep "^snort-inline=" /etc/packetprotector.conf | cut -d "=" -f 2`

# cleanup old logs

if [ "X$SNORT_INLINE_ENABLED" = "X1" ] ; then

   SNORTLOGDIR="/packetprotector/logs/snort-inline"
   SNORTLOGSIZE=`du -k $SNORTLOGDIR | cut -d"/" -f1`
   MAX_LOGSIZE=1000		# max log size (kilobytes) 

   echo 'Checking '$SNORTLOGDIR'.'

   if [ "$SNORTLOGSIZE" -gt "$MAX_LOGSIZE" ] ; then
	ALERTDONE=0
	LOGDONE=0
	while [ "$SNORTLOGSIZE" -gt "$MAX_LOGSIZE" ]
	do
		ALERTFILECOUNT=`ls $SNORTLOGDIR/alert* | wc -l`
		if [ "$ALERTFILECOUNT" -gt 2 ] ; then 
			rm `ls -t $SNORTLOGDIR/alert* | tail -1` 
		else 
			ALERTDONE=1 
		fi

		LOGFILECOUNT=`ls $SNORTLOGDIR/snort.log* | wc -l`
		if [ "$LOGFILECOUNT" -gt 2 ] ; then
			rm `ls -t $SNORTLOGDIR/snort.log* | tail -1`
		else
			LOGDONE=1
		fi

		if [ "$ALERTDONE" -eq 1 ] && [ "$LOGDONE" -eq 1 ] ; then
			SNORTLOGSIZE=0
		else
			SNORTLOGSIZE=`du -k $SNORTLOGDIR | cut -d"/" -f1`
		fi
	done
   else
	echo 'Nothing to do, '$SNORTLOGDIR' is less than '$MAX_LOGSIZE' kilobytes.'
   fi
fi
