#!/bin/bash

php_dir=/usr/local/php

echo "Please input your php path:"
read -p "(Default path: /usr/local/php):" php_dir
if [ "$php_dir" = "" ]; then
    php_dir=/usr/local/php
fi

sed -i 's/; cgi.fix_pathinfo=0/cgi.fix_pathinfo=0/g' $php_dir/etc/php.ini
$php_dir/sbin/php-fpm reload