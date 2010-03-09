<?
//Script to prune the redmonitor Table.

$hostname = 'localhost';
$username = '';
$password = '';
$dbname   = 'cacti';

// 900sec / 15min Timeout Session (should be the same as your setting in the vB options)
$datecut=time()-900;

$connection = mysql_connect($hostname,$username,$password) or die ("Cannot connect to server.");
$db = mysql_select_db($dbname,$connection) or die ("Could not select database.");

$sql = "DELETE FROM REDmonitor";
mysql_query($sql, $connection);

?> 