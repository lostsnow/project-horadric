<?php
/**
 * jsonp callback data
 */
$callback = isset($_GET['callback']) ? $_GET['callback'] : '';
//var_dump($_GET['callback']);
echo "{$callback}(" . json_encode(array('a' => 1, 'b' => 2)) . ")";
