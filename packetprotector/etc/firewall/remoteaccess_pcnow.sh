#!/bin/sh

if [ "X$1" = "Xblock" ] ; then
	#echo 'Blocking.'
	echo '127.0.0.2 dzramm1.mywebexpc.com' >> /etc/hosts
        echo '127.0.0.2 dzramm1p.mywebexpc.com' >> /etc/hosts
        echo '127.0.0.2 dzra1-1.mywebexpc.com' >> /etc/hosts
        echo '127.0.0.2 dzra1-2.mywebexpc.com' >> /etc/hosts
        echo '127.0.0.2 dzramm2.mywebexpc.com' >> /etc/hosts
        echo '127.0.0.2 dzramm2p.mywebexpc.com' >> /etc/hosts
        echo '127.0.0.2 dzra2-1.mywebexpc.com' >> /etc/hosts
        echo '127.0.0.2 dzra2-2.mywebexpc.com' >> /etc/hosts
        echo '127.0.0.2 dzra3.mywebexpc.com' >> /etc/hosts
        echo '127.0.0.2 dzra3-1.mywebexpc.com' >> /etc/hosts
        echo '127.0.0.2 dzra3-2.mywebexpc.com' >> /etc/hosts
        echo '127.0.0.2 dzra4.mywebexpc.com' >> /etc/hosts
        echo '127.0.0.2 dzra4-1.mywebexpc.com' >> /etc/hosts
        echo '127.0.0.2 dzra4-2.mywebexpc.com' >> /etc/hosts
        echo '127.0.0.2 dzra5.mywebexpc.com' >> /etc/hosts
        echo '127.0.0.2 dzra5-1.mywebexpc.com' >> /etc/hosts
        echo '127.0.0.2 dzra5-2.mywebexpc.com' >> /etc/hosts
        echo '127.0.0.2 dzra6.mywebexpc.com' >> /etc/hosts
        echo '127.0.0.2 dzra6-1.mywebexpc.com' >> /etc/hosts
        echo '127.0.0.2 dzra6-2.mywebexpc.com' >> /etc/hosts
        echo '127.0.0.2 dzra7.mywebexpc.com' >> /etc/hosts
        echo '127.0.0.2 dzra7-1.mywebexpc.com' >> /etc/hosts
        echo '127.0.0.2 dzra7-2.mywebexpc.com' >> /etc/hosts
        echo '127.0.0.2 dzra8.mywebexpc.com' >> /etc/hosts
        echo '127.0.0.2 dzra8-1.mywebexpc.com' >> /etc/hosts
        echo '127.0.0.2 dzra8-2.mywebexpc.com' >> /etc/hosts
        echo '127.0.0.2 dzra9.mywebexpc.com' >> /etc/hosts
        echo '127.0.0.2 dzra9-1.mywebexpc.com' >> /etc/hosts
        echo '127.0.0.2 dzra9-2.mywebexpc.com' >> /etc/hosts
        echo '127.0.0.2 dzra10.mywebexpc.com' >> /etc/hosts
        echo '127.0.0.2 dzra10-1.mywebexpc.com' >> /etc/hosts
        echo '127.0.0.2 dzra10-2.mywebexpc.com' >> /etc/hosts
        echo '127.0.0.2 dzra11.mywebexpc.com' >> /etc/hosts
        echo '127.0.0.2 dzra11-1.mywebexpc.com' >> /etc/hosts
        echo '127.0.0.2 dzra11-2.mywebexpc.com' >> /etc/hosts
        echo '127.0.0.2 dzra12.mywebexpc.com' >> /etc/hosts
        echo '127.0.0.2 dzra12-1.mywebexpc.com' >> /etc/hosts
        echo '127.0.0.2 dzra12-2.mywebexpc.com' >> /etc/hosts
	/usr/bin/killall -HUP dnsmasq
	
elif [ "X$1" = "Xunblock" ] ; then
	#echo 'Unblocking.'
	/bin/sed -i "/^127.0.0.2 dzramm1.mywebexpc.com/d" /etc/hosts
	/bin/sed -i "/^127.0.0.2 dzramm1p.mywebexpc.com/d" /etc/hosts
	/bin/sed -i "/^127.0.0.2 dzra1-1.mywebexpc.com/d" /etc/hosts
	/bin/sed -i "/^127.0.0.2 dzra1-2.mywebexpc.com/d" /etc/hosts
	/bin/sed -i "/^127.0.0.2 dzramm2.mywebexpc.com/d" /etc/hosts
	/bin/sed -i "/^127.0.0.2 dzramm2p.mywebexpc.com/d" /etc/hosts
	/bin/sed -i "/^127.0.0.2 dzra2-1.mywebexpc.com/d" /etc/hosts
	/bin/sed -i "/^127.0.0.2 dzra2-2.mywebexpc.com/d" /etc/hosts
	/bin/sed -i "/^127.0.0.2 dzra3.mywebexpc.com/d" /etc/hosts
	/bin/sed -i "/^127.0.0.2 dzra3-1.mywebexpc.com/d" /etc/hosts
	/bin/sed -i "/^127.0.0.2 dzra3-2.mywebexpc.com/d" /etc/hosts
	/bin/sed -i "/^127.0.0.2 dzra4.mywebexpc.com/d" /etc/hosts
	/bin/sed -i "/^127.0.0.2 dzra4-1.mywebexpc.com/d" /etc/hosts
	/bin/sed -i "/^127.0.0.2 dzra4-2.mywebexpc.com/d" /etc/hosts
	/bin/sed -i "/^127.0.0.2 dzra5.mywebexpc.com/d" /etc/hosts
	/bin/sed -i "/^127.0.0.2 dzra5-1.mywebexpc.com/d" /etc/hosts
	/bin/sed -i "/^127.0.0.2 dzra5-2.mywebexpc.com/d" /etc/hosts
	/bin/sed -i "/^127.0.0.2 dzra6.mywebexpc.com/d" /etc/hosts
	/bin/sed -i "/^127.0.0.2 dzra6-1.mywebexpc.com/d" /etc/hosts
	/bin/sed -i "/^127.0.0.2 dzra6-2.mywebexpc.com/d" /etc/hosts
	/bin/sed -i "/^127.0.0.2 dzra7.mywebexpc.com/d" /etc/hosts
	/bin/sed -i "/^127.0.0.2 dzra7-1.mywebexpc.com/d" /etc/hosts
	/bin/sed -i "/^127.0.0.2 dzra7-2.mywebexpc.com/d" /etc/hosts
	/bin/sed -i "/^127.0.0.2 dzra8.mywebexpc.com/d" /etc/hosts
	/bin/sed -i "/^127.0.0.2 dzra8-1.mywebexpc.com/d" /etc/hosts
	/bin/sed -i "/^127.0.0.2 dzra8-2.mywebexpc.com/d" /etc/hosts
	/bin/sed -i "/^127.0.0.2 dzra9.mywebexpc.com/d" /etc/hosts
	/bin/sed -i "/^127.0.0.2 dzra9-1.mywebexpc.com/d" /etc/hosts
	/bin/sed -i "/^127.0.0.2 dzra9-2.mywebexpc.com/d" /etc/hosts
	/bin/sed -i "/^127.0.0.2 dzra10.mywebexpc.com/d" /etc/hosts
	/bin/sed -i "/^127.0.0.2 dzra10-1.mywebexpc.com/d" /etc/hosts
	/bin/sed -i "/^127.0.0.2 dzra10-2.mywebexpc.com/d" /etc/hosts
	/bin/sed -i "/^127.0.0.2 dzra11.mywebexpc.com/d" /etc/hosts
	/bin/sed -i "/^127.0.0.2 dzra11-1.mywebexpc.com/d" /etc/hosts
	/bin/sed -i "/^127.0.0.2 dzra11-2.mywebexpc.com/d" /etc/hosts
	/bin/sed -i "/^127.0.0.2 dzra12.mywebexpc.com/d" /etc/hosts
	/bin/sed -i "/^127.0.0.2 dzra12-1.mywebexpc.com/d" /etc/hosts
	/bin/sed -i "/^127.0.0.2 dzra12-2.mywebexpc.com/d" /etc/hosts
	/usr/bin/killall -HUP dnsmasq
	
else
	echo 'Usage- '$0' block|unblock'
fi
