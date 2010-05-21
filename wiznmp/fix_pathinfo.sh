#!/bin/bash

php_dir=$1

if [ ! $php_dir ] || [ ! -d $php_dir ]; then
    echo "Please input your php path:"
    read -p "(Default path: /usr/local/php):" php_dir
    if [ ! $php_dir ]; then
        php_dir=/usr/local/php
    else
        if [ ! -d $php_dir ]; then
            echo "invalid directory."
            exit 0
        fi
    fi
fi

echo ""
echo "current php.ini"
cat $php_dir/etc/php.ini |grep fix_pathinfo
echo ""
echo "modify php.ini"
sed -i 's/; cgi.fix_pathinfo=0/cgi.fix_pathinfo=0/g' $php_dir/etc/php.ini
cat $php_dir/etc/php.ini |grep fix_pathinfo
echo ""
echo "reload php.ini"
$php_dir/sbin/php-fpm reload
