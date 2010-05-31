<?php
/**
 * cookie data
 */

header('P3P: CP="CURa ADMa DEVa PSAo PSDo OUR BUS UNI PUR INT DEM STA PRE COM NAV OTC NOI DSP COR"');
$cookie = !empty($_GET['id']) ? $_GET['id'] : 'none';
setcookie("cd-p3p", $cookie, time() + 3600, "/", ".c.com");
