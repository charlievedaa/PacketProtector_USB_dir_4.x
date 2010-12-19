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
			<div id="mainmenu"><h3>User</h3></div>
			<div id="submenu"><ul><li><b>Password Change</b></li></ul></div>

        </div>

        <div id="content">
			
<br /><br />
<? 


echo $REMOTE_USER

?>

        </div>
</div>
</body>

</html>
