#!/usr/bin/webif-page

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
<head>

<?
if [ "X$REMOTE_USER" = "Xroot" ] ; then
        echo '<meta http-equiv="refresh" content="0; URL=/cgi-bin/webif/info.sh" />'
else
        echo '<meta http-equiv="refresh" content="0; URL=/cgi-bin/webif/vpn/VPNconnect.sh" />'
fi
?>

<title>PacketProtector Administration Console</title>
<style type="text/css">
*{color:#CCC;background:#000;font-family:Verdana,Helvetica,sans-serif}
p{position:absolute;width:99%;top:50%;margin-top:-3em;line-height:3em;text-align:center}
</style>
</head>
<body>
<p><b>PacketProtector Administration Console<br />
Redirecting...</p>
</body>
</html>
