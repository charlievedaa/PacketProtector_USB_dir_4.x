#!/usr/bin/webif-page
<? 
. /usr/lib/webif/webif.sh

header "Network" "Advanced Firewall" "@TR<<Advanced Firewall Configuration>>"

prepare_files()
{
        if [ -h /etc/advanced_firewall.conf ] ; then
                cp /etc/advanced_firewall.conf /etc/advanced_firewall.conf.ORIG
                rm /etc/advanced_firewall.conf
                cp /rom/etc/advanced_firewall.conf /etc/advanced_firewall.conf
        fi
}

BASEDIR=/packetprotector
WAN=`uci get network.wan.ifname`

echo '<script language="javascript">'
echo 'function selectAll(theElement)'
echo '{'
echo '   var formObj = theElement.form;' 
echo '   for (var i=0;i < formObj.length;i++) {'
echo '      fldObj = formObj.elements[i];'
echo '      var catNameString=theElement.name;'
echo '      var fldNameString=fldObj.name;'
echo '      var catNameArray=catNameString.split("_");'
echo '      var fldNameArray=fldNameString.split("_");'
echo '      if (fldObj.type == "checkbox" && catNameArray[0] == fldNameArray[0]) {'
echo '         fldObj.checked = theElement.checked;'
echo '      }'
echo '   }'
echo '}'
echo '</script>'

CHANGED=0
for i in `cat /etc/advanced_firewall.conf`; do
        VAR=`echo $i | cut -d "=" -f1`
        CURRENT_VALUE=`echo $i | cut -d "=" -f2`
        FORM_VAR="FORM_$VAR"        	
        eval "FORM_VAR_VALUE=\$$FORM_VAR"
	#echo $FORM_VAR $FORM_VAR_VALUE
	#echo '<br />'

	#UNBLOCKED -> BLOCKED
        if [ "X$FORM_VAR_VALUE" = "X1" ] && [ "X$FORM_VAR_VALUE" != "X$CURRENT_VALUE" ] ; then
		prepare_files
       		$BASEDIR/etc/firewall/$VAR.sh block
       		/bin/sed -i "s/^$VAR=$CURRENT_VALUE/$VAR=1/" /etc/advanced_firewall.conf
       		eval "$VAR=1"
		CHANGED=1
        elif [ "X$FORM_VAR_VALUE" = "Xblock" ] && [ "X$FORM_VAR_VALUE" != "X$CURRENT_VALUE" ] ; then
		prepare_files
       		$BASEDIR/etc/firewall/$VAR.sh block
       		/bin/sed -i "s/^$VAR=$CURRENT_VALUE/$VAR=block/" /etc/advanced_firewall.conf
       		eval "$VAR=block"
		CHANGED=1

       	#BLOCKED AND UNCHANGED
       	elif [ "X$FORM_VAR_VALUE" = "X$CURRENT_VALUE" ] ; then 
        	eval "$VAR=$CURRENT_VALUE"

        #BLOCKED -> UNBLOCKED
        elif [ "X$FORM_VAR_VALUE" = "Xunblock" ] && [ "X$FORM_VAR_VALUE" != "X$CURRENT_VALUE" ] ; then
		prepare_files
       		$BASEDIR/etc/firewall/$VAR.sh unblock
       		/bin/sed -i "s/^$VAR=$CURRENT_VALUE/$VAR=unblock/" /etc/advanced_firewall.conf
       		eval "$VAR=unblock"
		CHANGED=1
       	elif [ "X$CURRENT_VALUE" = "X1" ] && [ "X$REQUEST_METHOD" = "XPOST" ] ; then
		prepare_files
        	$BASEDIR/etc/firewall/$VAR.sh unblock
       		/bin/sed -i "s/^$VAR=$CURRENT_VALUE/$VAR=0/" /etc/advanced_firewall.conf
       		eval "$VAR=0"
		CHANGED=1

       	#UNBLOCKED AND UNCHANGED
        else
        	eval "$VAR=$CURRENT_VALUE"
        fi 
done

if [ "$CHANGED" = "1" ] ; then
		/etc/init.d/webiffirewalllog stop 2> /dev/null
		/etc/init.d/webiffirewalllog start
		echo 'Done!<br /><br />'
fi

echo '<form name="firewall" enctype="multipart/form-data" method="post">'

echo '<table CELLSPACING="5">'

echo '<tr>'
echo '<td>Allow OpenVPN clients to connect?'
if [ "X$openvpn_from_outside" = "Xunblock" ] ; then
        echo '<td><input type="radio" name="openvpn_from_outside" value="unblock" checked> Yes'
        echo '<td><input type="radio" name="openvpn_from_outside" value="block"> No'
else
        echo '<td><input type="radio" name="openvpn_from_outside" value="unblock"> Yes'
        echo '<td><input type="radio" name="openvpn_from_outside" value="block" checked> No'
fi
echo '</tr>'

echo '<tr>'
echo '<td>Allow Internet access for VPN clients?'
if [ "X$openvpn_to_internet" = "Xunblock" ] ; then
        echo '<td><input type="radio" name="openvpn_to_internet" value="unblock" checked> Yes'
        echo '<td><input type="radio" name="openvpn_to_internet" value="block"> No'
else
        echo '<td><input type="radio" name="openvpn_to_internet" value="unblock"> Yes'
        echo '<td><input type="radio" name="openvpn_to_internet" value="block" checked> No'
fi
echo '</tr>'

echo '<tr>'
echo '<td>Allow access to the web interface (HTTPS) from the internet?'
if [ "X$https_from_outside" = "Xunblock" ] ; then
        echo '<td><input type="radio" name="https_from_outside" value="unblock" checked> Yes'
	echo '<td><input type="radio" name="https_from_outside" value="block"> No'
else
	echo '<td><input type="radio" name="https_from_outside" value="unblock"> Yes'
        echo '<td><input type="radio" name="https_from_outside" value="block" checked> No'
fi
echo '</tr>'

echo '<tr>'
echo '<td>Allow shell access (SSH) from the internet?'
if [ "X$ssh_from_outside" = "Xunblock" ] ; then
        echo '<td><input type="radio" name="ssh_from_outside" value="unblock" checked> Yes'
	echo '<td><input type="radio" name="ssh_from_outside" value="block"> No'
else
	echo '<td><input type="radio" name="ssh_from_outside" value="unblock"> Yes'
        echo '<td><input type="radio" name="ssh_from_outside" value="block" checked> No'
fi
echo '</tr>'

echo '<tr>'
echo '<td>Allow access to external DNS servers?'
if [ "X$external_dns" = "X0" ] ; then
        echo '<td><input type="radio" name="external_dns" value="0" checked> Yes'
        echo '<td><input type="radio" name="external_dns" value="1"> No'
else
        echo '<td><input type="radio" name="external_dns" value="0"> Yes'
        echo '<td><input type="radio" name="external_dns" value="1" checked> No'
fi
echo '</tr>'

echo '<tr>'
echo '<td>Allow VOIP (Skype, TeamSpeak, H.323, SIP)?'
if [ "X$voip" = "X0" ] ; then
        echo '<td><input type="radio" name="voip" value="0" checked> Yes'
        echo '<td><input type="radio" name="voip" value="1"> No'
else
        echo '<td><input type="radio" name="voip" value="0"> Yes'
        echo '<td><input type="radio" name="voip" value="1" checked> No'
fi
echo '</tr>'

echo '<tr>'
echo '<td>Allow anomalous packets (e.g. TCP SYN+FIN)?'
if [ "X$ipt_unclean" = "X0" ] ; then
        echo '<td><input type="radio" name="ipt_unclean" value="0" checked> Yes'
        echo '<td><input type="radio" name="ipt_unclean" value="1"> No'
else
        echo '<td><input type="radio" name="ipt_unclean" value="0"> Yes'
        echo '<td><input type="radio" name="ipt_unclean" value="1" checked> No'
fi
echo '</tr>'

echo '<tr>'
echo '<td><input type="submit" name="submit_https" value="Submit">'
echo '<td>&nbsp <td>&nbsp'
echo '</tr>'
echo '</table>'

echo '<br />'

echo '<b>Chat and Instant Messaging (IM)</b>'
echo '<br /><br />'
if [ "X$chat_aim" = "X1" ] && [ "X$chat_googletalk" = "X1" ] && [ "X$chat_IRC" = "X1" ] && [ "X$chat_MS" = "X1" ] && [ "X$chat_yahoomessenger" = "X1" ] ; then
	echo '<input type="checkbox" name="chat_all" onclick="selectAll(this);" checked> Block all chat/IM.<br />'
else
	echo '<input type="checkbox" name="chat_all" onclick="selectAll(this);"> Block all chat/IM.<br />'
fi
if [ "X$chat_aim" = "X1" ] ; then
	echo '<input type="checkbox" name="chat_aim" value="1" checked> Block AOL Instant Messenger.<br />'
else
	echo '<input type="checkbox" name="chat_aim" value="1"> Block AOL Instant Messenger.<br />'
fi
if [ "X$chat_googletalk" = "X1" ] ; then
	echo '<input type="checkbox" name="chat_googletalk" value="1" checked> Block Google Talk.<br />'
else
	echo '<input type="checkbox" name="chat_googletalk" value="1"> Block Google Talk.<br />'
fi
if [ "X$chat_IRC" = "X1" ] ; then
	echo '<input type="checkbox" name="chat_IRC" value="1" checked> Block IRC.<br />'
else
	echo '<input type="checkbox" name="chat_IRC" value="1"> Block IRC.<br />'
fi
if [ "X$chat_MS" = "X1" ] ; then
	echo '<input type="checkbox" name="chat_MS" value="1" checked> Block MSN/Windows Messenger.<br />'
else
	echo '<input type="checkbox" name="chat_MS" value="1"> Block MSN/Windows Messenger.<br />'
fi
if [ "X$chat_yahoomessenger" = "X1" ] ; then
	echo '<input type="checkbox" name="chat_yahoomessenger" value="1" checked> Block Yahoo! Messenger.<br />'
else
	echo '<input type="checkbox" name="chat_yahoomessenger" value="1"> Block Yahoo! Messenger.<br />'
fi

echo '<input type="submit" name="submit_chat" value="Submit">'
echo '<br/>'

echo '<br/>'
echo '<b>Peer to Peer (P2P)</b>'
echo '<br /><br />'
if [ "X$p2p_bittorrent" = "X1" ] && [ "X$p2p_edonkey" = "X1" ] && [ "X$p2p_gnutella" = "X1" ] && [ "X$p2p_kazaa" = "X1" ] && [ "X$p2p_others" = "X1" ] ; then
	echo '<input type="checkbox" name="p2p_all" onclick="selectAll(this);" checked> Block all P2P.<br />'
else
	echo '<input type="checkbox" name="p2p_all" onclick="selectAll(this);"> Block all P2P.<br />'
fi
if [ "X$p2p_bittorrent" = "X1" ] ; then
	echo '<input type="checkbox" name="p2p_bittorrent" value="1" checked> Block BitTorrent.<br />'
else
	echo '<input type="checkbox" name="p2p_bittorrent" value="1"> Block BitTorrent.<br />'
fi
if [ "X$p2p_edonkey" = "X1" ] ; then
	echo '<input type="checkbox" name="p2p_edonkey" value="1" checked> Block eDonkey/eMule/Overnet.<br />'
else
	echo '<input type="checkbox" name="p2p_edonkey" value="1"> Block eDonkey/eMule/Overnet.<br />'
fi
if [ "X$p2p_gnutella" = "X1" ] ; then
	echo '<input type="checkbox" name="p2p_gnutella" value="1" checked> Block Gnutella (BearShare, LimeWire, etc).<br />'
else
	echo '<input type="checkbox" name="p2p_gnutella" value="1"> Block Gnutella (BearShare, LimeWire, etc).<br />'
fi
if [ "X$p2p_kazaa" = "X1" ] ; then
	echo '<input type="checkbox" name="p2p_kazaa" value="1" checked> Block KaZaA.<br />'
else
	echo '<input type="checkbox" name="p2p_kazaa" value="1"> Block KaZaA.<br />'
fi
if [ "X$p2p_others" = "X1" ] ; then
	echo '<input type="checkbox" name="p2p_others" value="1" checked> Block others (AppleJuice, Ares, SoulSeek).<br />'
else
	echo '<input type="checkbox" name="p2p_others" value="1"> Block others (AppleJuice, Ares, SoulSeek).<br />'
fi

echo '<input type="submit" name="submit_chat" value="Submit">'
echo '<br/>'

echo '<br/>'
echo '<b>Remote Access</b>'
echo '<br /><br />'
if [ "X$remoteaccess_gotomypc" = "X1" ] && [ "X$remoteaccess_logmein" = "X1" ] && [ "X$remoteaccess_pcnow" = "X1" ] ; then
	echo '<input type="checkbox" name="remoteaccess_all" onclick="selectAll(this);" checked> Block all remote access.<br />'
else
	echo '<input type="checkbox" name="remoteaccess_all" onclick="selectAll(this);"> Block all remote access.<br />'
fi
if [ "X$remoteaccess_gotomypc" = "X1" ] ; then
	echo '<input type="checkbox" name="remoteaccess_gotomypc" value="1" checked> Block GoToMyPC.<br />'
else
	echo '<input type="checkbox" name="remoteaccess_gotomypc" value="1"> Block GoToMyPC.<br />'
fi
if [ "X$remoteaccess_logmein" = "X1" ] ; then
	echo '<input type="checkbox" name="remoteaccess_logmein" value="1" checked> Block LogMeIn.<br />'
else
	echo '<input type="checkbox" name="remoteaccess_logmein" value="1"> Block LogMeIn.<br />'
fi
if [ "X$remoteaccess_pcnow" = "X1" ] ; then
	echo '<input type="checkbox" name="remoteaccess_pcnow" value="1" checked> Block PCNow.<br />'
else
	echo '<input type="checkbox" name="remoteaccess_pcnow" value="1"> Block PCNow.<br />'
fi

echo '<input type="submit" name="submit_chat" value="Submit">'
echo '<br/>'

echo '</form>'

#echo $REMOTE_ADDR
#echo $REMOTE_USER

footer ?>
<!--
##WEBIF:name:Network:416:Advanced Firewall
-->
