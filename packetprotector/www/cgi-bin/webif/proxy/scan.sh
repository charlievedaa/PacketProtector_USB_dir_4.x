#!/usr/bin/webif-page

<html>

<head>
        <title>PacketProtector Admin Console</title>
	<link rel="stylesheet" type="text/css" href="/themes/active/webif.css">
	<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">

</head>
<body>
<div id="container">
        <div id="header">
                <div id="header-title">
				<div id="openwrt-title"><h1>PacketProtector Admin Console</h1></div>
				<div id="short-status">
                                        <h3><strong>Status:</strong></h3>
                                        <ul>
                                                <li>*</li>
                                                <li>*</li>
                                                <li>*</li>
                                                <li>*</li>
                                        </ul>
                                </div>
		</div>
			<div id="mainmenu"><h3>Proxy</h3></div>
			<div id="submenu"><ul><li><b>Virus Scan</b></li></ul></div>

        </div>

        <div id="content">
			
<br /><br />
<? 

max_size=5000000
LD_LIBRARY_PATH=/packetprotector/usr/lib/
filename=`basename $FORM_url`
extension=`echo $filename | awk -F . '{print $NF}'`

cd /packetprotector/tmp
content_length=`/packetprotector/usr/sbin/curl --head $FORM_url 2> /dev/null | grep Content-Length`
if [ $? -eq 0 ] ; then
	length=`echo $content_length | cut -d " " -f2`
else
	length=0
fi
#echo $FORM_url
#echo "<br />"
#/packetprotector/usr/sbin/curl --head $FORM_url
if [ $length -gt 0 ] ; then
	echo "File is "$length" bytes.<br />"
else
	echo "No content-length header found.<br />"
fi
echo "<br />"

if [ "$length" -gt "$max_size" ] ; then
	echo "Maximum file size for AV scanning is "$max_size" bytes.<br />"
        echo "<br />"
        echo '<form id="bypass" action="https://local.packetprotector.org/cgi-bin/webif/proxy/bypass.sh" method=post">'
	echo '<input type="hidden" name="sourceip" value ="'$FORM_sourceip'"/>'
 	echo '<input type="hidden" name="url" value ="'$FORM_url'"/>'
        echo '<input type="submit" value="download" />'
        echo "(file was not scanned)"
	echo "</form>"
        echo "<br />"
else
	echo "Downloading...<br />"
	echo "<br />"
	epoch=`date +%s`
	random=`echo $RANDOM`
	dir_name=`echo $epoch$RANDOM`
	mkdir $dir_name
	cd $dir_name
   contains_question=`echo -n $filename | grep ?` 
   if [[ $? -eq 0 ]] ; then
	filename=`echo $filename | cut -d? -f1`
   fi
   wget -q $FORM_url -O $filename 
   if [ $? -eq 0 ] ; then
	echo "Done.<br />"
	echo "<br />"
	if [ "X$extension" = "Xzip" ] ; then
		length=`/packetprotector/usr/sbin/zipinfo -t $filename | cut -d " " -f 3`
		echo ".zip file is "$length" bytes uncompressed.<br />"
		echo "<br />"
	fi
	echo "Scanning...<br />"
	echo "<br />"
	echo "<pre>"
	/packetprotector/usr/sbin/clamscan --tempdir=/packetprotector/tmp/clamscan $filename 
	result=$?
	cd /packetprotector/tmp
	rm -rf $dir_name
	echo "</pre>"
	echo "<br />"
	echo "Complete.<br />"
	echo "<br />"
	if [ "$result" = "0" ] ; then
        	echo '<form id="bypass" action="https://local.packetprotector.org/cgi-bin/webif/proxy/bypass.sh" method=post">'
		echo '<input type="hidden" name="sourceip" value ="'$FORM_sourceip'"/>'
 		echo '<input type="hidden" name="url" value ="'$FORM_url'"/>'
        	echo '<input type="submit" value="download" />'
        	echo "(file scanned successfully)"
		echo "</form>"
        	echo "<br />"
	elif [ "$result" = "1" ] ; then
		echo "VIRUS FOUND!"
	else
		echo "SCAN FAILED!"
        	echo "<br />"
		echo "Return code was "$result"."
	fi
   else
	echo "Download failed."
   fi	
fi

?>

        </div>
</div>
</body>

</html>
