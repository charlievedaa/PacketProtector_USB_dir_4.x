#!/usr/bin/webif-page
<?
. /usr/lib/webif/webif.sh
###################################################################
# About PP page
#
# Description:
#        Shows the many contributors.
#
# Author(s) :
#       cmh714
#
# Major revisions:
#
# Configuration files referenced:
#   none
#
header "Info" "About PP" "<img src=\"/images/abt.jpg\" alt=\"@TR<<About PP>>\" />@TR<<About PP>>"

?>
<script src="/js/scrollbox.js" type="text/javascript"></script>
<h2><a href="http://www.packetprotector.org">@TR<<PacketProtector>></a></h2>

<div id="outerscrollBox"  onMouseOver="copyspeed=pausespeed" onMouseOut="copyspeed=marqueespeed">

<div id="scrollBox">

<h1>@TR<<PacketProtector Credits>></h1>
<h2>@TR<<Primary Developer>> <em>(@TR<<sorted_by_name#sorted by name>>)</em></h2>
<ul>
	<li><a href="mailto:charlie@packetprotector.org">Charlie aka ciscostu</a></li>
</ul>

<h2>@TR<<Contributing Developers>> <em>(@TR<<sorted_by_name#sorted by name>>)</em></h2>

<ul>
	<li><a href="https://packetprotector.org/forum/misc.php?email=4806">Craig aka cmh714</a></li>
</ul>

<h2>@TR<<Other Contributions>></h2>
<ul>
</ul>

<p>@TR<<This device is running>> <a href="http://www.openwrt.org">OpenWrt</a> @TR<<or a close derivative>>.</p>

<p>@TR<<GPL_Text#This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version.>></p>

</div></div> <!-- End scrollBox -->

<? footer ?>
<!--
##WEBIF:name:Info:960:About PP
-->
