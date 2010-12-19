#!/usr/bin/webif-page

<html>

<head>
        <title>PacketProtector Admin Console</title>
	<link rel="stylesheet" type="text/css" href="/themes/active/webif.css">
	<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">

<?
slashcount=`echo -n $FORM_url | awk -F/ '{print NF-1}'`
#echo $slashcount
#echo "<br />"
if [ $slashcount -eq 2 ] ; then
	FORM_url=$FORM_url/	
fi
filename=`basename $FORM_url`
magic="packetprotector"
date=`date +%s`
date=`expr $date + 600`
md5=`echo -n $FORM_url$magic$FORM_sourceip$date | md5sum | cut -d " " -f1`
bypass=`echo -n $md5$date | tr 'a-z' 'A-Z'`
contains_question=`echo -n $FORM_url | grep ?`
if [[ $? -eq 0 ]] ; then
	gbypass="&GBYPASS="
else
	gbypass="?GBYPASS="
fi
url=`echo -n $FORM_url$gbypass$bypass`
	
	echo '<meta http-equiv="refresh" content="1; URL='$url'" />'	
?>

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
			<div id="submenu"><ul><li><b>Bypass</b></li></ul></div>

        </div>

        <div id="content">
			
<br /><br />
<? 

?>

        </div>
</div>
</body>

</html>
