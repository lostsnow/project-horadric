#!/bin/bash

# Check if user is root
if [ $(id -u) != "0" ]; then
    echo "Error: You must be root to run this script, please use root to install wiznpm"
    echo "You can use this command: \"sudo su -\" and type your password"
    exit 1
fi

#---------------------config start-------------------------
nginx_version="0.7.64"
php_version="5.2.11"
mysql_version="5.1.42"
php_fpm_version="0.5.13"
libiconv_version="1.13.1"
libmcrypt_version="2.5.8"
mcrypt_version="2.6.8"
memcached_version="1.4.4"
pecl_memcache_version="2.2.5"
mhash_version="0.9.9.9"
pcre_version="8.00"
#eaccelerator_version="0.9.5.3"
PDO_MYSQL_version="1.0.2"

nginx_tar_gz_name="nginx-"$nginx_version".tar.gz"
php_tar_gz_name="php-"$php_version".tar.gz"
mysql_tar_gz_name="mysql-"$mysql_version".tar.gz"
php_fpm_tar_gz_name="php-"$php_version"-fpm-"$php_fpm_version".diff.gz"
libiconv_tar_gz_name="libiconv-"$libiconv_version".tar.gz"
libmcrypt_tar_gz_name="libmcrypt-"$libmcrypt_version".tar.gz"
mcrypt_tar_gz_name="mcrypt-"$mcrypt_version".tar.gz"
memcached_tar_gz_name="memcached-"$memcached_version".tar.gz"
pecl_memcache_tar_gz_name="memcache-"$pecl_memcache_version".tgz"
mhash_tar_gz_name="mhash-"$mhash_version".tar.gz"
pcre_tar_gz_name="pcre-"$pcre_version".tar.gz"
#eaccelerator_tar_gz_name="eaccelerator-"$eaccelerator_version".tar.bz2"
PDO_MYSQL_tar_gz_name="PDO_MYSQL-"$PDO_MYSQL_version".tgz"

nginx_source_dir_name="nginx-"$nginx_version
php_source_dir_name="php-"$php_version
mysql_source_dir_name="mysql-"$mysql_version
php_fpm_source_dir_name="php-"$php_version"-fpm-"$php_fpm_version
libiconv_source_dir_name="libiconv-"$libiconv_version
libmcrypt_source_dir_name="libmcrypt-"$libmcrypt_version
mcrypt_source_dir_name="mcrypt-"$mcrypt_version
memcache_source_dir_name="memcached-"$memcached_version
pecl_memcache_source_dir_name="memcache-"$pecl_memcache_version
mhash_source_dir_name="mhash-"$mhash_version
pcre_source_dir_name="pcre-"$pcre_version
#eaccelerator_source_dir_name="eaccelerator-"$eaccelerator_version
PDO_MYSQL_source_dir_name="PDO_MYSQL-"$PDO_MYSQL_version

base_download_url="http://project-horadric.googlecode.com/svn/tags/src/"
nginx_download_url=$base_download_url$nginx_tar_gz_name
php_download_url=$base_download_url$php_tar_gz_name
mysql_download_url=$base_download_url$mysql_tar_gz_name
php_fpm_download_url=$base_download_url$php_fpm_tar_gz_name
libiconv_download_url=$base_download_url$libiconv_tar_gz_name
libmcrypt_download_url=$base_download_url$libmcrypt_tar_gz_name
mcrypt_download_url=$base_download_url$mcrypt_tar_gz_name
memcached_download_url=$base_download_url$memcached_tar_gz_name
pecl_memcache_download_url=$base_download_url$pecl_memcache_tar_gz_name
mhash_download_url=$base_download_url$mhash_tar_gz_name
pcre_download_url=$base_download_url$pcre_tar_gz_name
#eaccelerator_download_url=$base_download_url$eaccelerator_tar_gz_name
PDO_MYSQL_download_url=$base_download_url$PDO_MYSQL_tar_gz_name

nginx_dir="/usr/local/nginx"
php_dir="/usr/local/php"
mysql_dir="/usr/local/mysql"
mysql_data_dir="/var/lib/mysql"
memcached_dir="/usr/local/memcached"
web_dir="/var/www"
log_dir="/var/log/nginx"

# apt source file for ubuntu 9.10
# you can get other versions from: http://mirrors.sohu.com/help/ubuntu.html
apt_source="sources.list.sohu.karmic"
apt_bak_name="sources.list."`date '+%Y%m%d%H%M%S'`
#apt_source_url=$base_download_url$apt_source

#---------------------config end---------------------------

clear
echo "========================================================================="
echo "  Wiznmp v0.1 for Ubuntu"
echo "  Author: lostsnow (lostsnow@gmail.com)"
echo "========================================================================="
echo "A tool to auto-compile & install Nginx+MySQL+PHP on Linux"
echo "For more information please visit http://www.lsproc.com/blog/"
echo ""
echo ""
echo "The path of some dirs:"
echo "  mysql dir:        "$mysql_dir
echo "  php dir:          "$php_dir
echo "  nginx dir:        "$nginx_dir
echo "  memcached dir     "$memcached_dir
echo "  web dir           "$web_dir
echo ""
echo "Note: you must run this script(./ubuntu.sh) after \"chmod +x ubuntu.sh\", "
echo "      do not use \"sh ./ubuntu.sh\""
echo ""
echo "========================================================================="
cur_dir=$(pwd)

if [ "$1" != "--help" ]; then

    domain="localhost"
    echo "Please input domain:"
    read -p "(Default domain: localhost):" domain
    if [ "$domain" = "" ]; then
        domain="localhost"
    fi

    echo "==========================="
    echo domain="$domain"

    echo ""
    echo "Where do you want to get the sources of Nginx, PHP, MySQL and so on from?"
    select sources_from in "Download from Internet." "Current directory."; do
    break
    done

    select install_memcached in "Yes" "No"; do
    break
    done

    get_char()
    {
        SAVEDSTTY=`stty -g`
        stty -echo
        stty cbreak
        dd if=/dev/tty bs=1 count=1 2> /dev/null
        stty -raw
        stty echo
        stty $SAVEDSTTY
    }
    echo ""
    echo "It will take some time to auto-compile & install Nginx, PHP, MySQL."
    echo "Press any key to start..."
    char=`get_char`

echo "===================download and check files start========================"

if [ "$sources_from" = "Download from Internet." ]; then
    rm -f $nginx_tar_gz_name
    wget -c $nginx_download_url
    rm -f $php_tar_gz_name
    wget -c $php_download_url
    rm -f $mysql_tar_gz_name
    wget -c $mysql_download_url
    rm -f $php_fpm_tar_gz_name
    wget -c $php_fpm_download_url
    rm -f $libiconv_tar_gz_name
    wget -c $libiconv_download_url
    rm -f $pecl_memcache_tar_gz_name
    wget -c $pecl_memcache_download_url
#    rm -f $eaccelerator_tar_gz_name
#    wget -c $eaccelerator_download_url
    rm -f $PDO_MYSQL_tar_gz_name
    wget -c $PDO_MYSQL_download_url
#    rm -f $yum_source
#    wget -c $yum_source_url
fi

if [ "$install_memcached" = "Yes" ]; then
    if [ "$sources_from" = "Download from Internet." ]; then
        rm -f $memcached_tar_gz_name
        wget -c $memcached_download_url
    fi
fi

echo "checking files"
if [ -s $nginx_tar_gz_name ]; then
    echo "$nginx_tar_gz_name [found]"
    else
    echo ""
    echo "Error: $nginx_tar_gz_name not found!!!"
    exit 0
fi

if [ -s $php_tar_gz_name ]; then
    echo "$php_tar_gz_name [found]"
    else
    echo ""
    echo "Error: $php_tar_gz_name not found!!!"
    exit 0
fi

if [ -s $mysql_tar_gz_name ]; then
    echo "$mysql_tar_gz_name [found]"
    else
    echo ""
    echo "Error: $mysql_tar_gz_name not found!!!"
    exit 0
fi

if [ -s $php_fpm_tar_gz_name ]; then
    echo "$php_fpm_tar_gz_name [found]"
    else
    echo ""
    echo "Error: $php_fpm_tar_gz_name not found!!!"
    exit 0
fi

if [ -s $libiconv_tar_gz_name ]; then
    echo "$libiconv_tar_gz_name [found]"
    else
    echo ""
    echo "Error: $libiconv_tar_gz_name not found!!!"
    exit 0
fi

if [ -s $pecl_memcache_tar_gz_name ]; then
    echo "$pecl_memcache_tar_gz_name [found]"
    else
    echo ""
    echo "Error: $pecl_memcache_tar_gz_name not found!!!"
    exit 0
fi

#if [ -s $eaccelerator_tar_gz_name ]; then
#  echo "$eaccelerator_tar_gz_name [found]"
#  else
#  echo ""
#  echo "Error: $eaccelerator_tar_gz_name not found!!!"
#  exit 0
#fi

if [ -s $PDO_MYSQL_tar_gz_name ]; then
    echo "$PDO_MYSQL_tar_gz_name [found]"
    else
    echo ""
    echo "Error: $PDO_MYSQL_tar_gz_name not found!!!"
    exit 0
fi

#if [ -s $yum_source ]; then
#    echo "$yum_source [found]"
#    else
#    echo ""
#    echo "Error: $yum_source not found!!!"
#    exit 0
#fi

if [ "$install_memcached" = "Yes" ]; then
    if [ -s $memcached_tar_gz_name ]; then
        echo "$memcached_tar_gz_name [found]"
        else
        echo ""
        echo "Error: $memcached_tar_gz_name not found!!!"
        exit 0
    fi
fi

echo "====================download and check files end========================="

echo "===========update apt source file and update system start================"
apt-get update -y
apt-get install -y build-essential gcc g++ ssh automake autoconf make re2c wget cron bzip2 rcconf vim m4 awk cpp binutils unzip tar chkconfig ntp
apt-get install -y libncurses5 libncurses5-dev libtool libpcrecpp0 libssl-dev zlibc openssl
apt-get install -y libxml2-dev libltdl3-dev libmcrypt-dev libbz2-dev libpcre3 libpcre3-dev
apt-get install -y libssl-dev zlib1g-dev libpng3 libfreetype6 libfreetype6-dev libjpeg62 libjpeg62-dev
apt-get install -y libpng12-0 libpng12-dev
apt-get install -y curl libcurl3 libcurl3-dev libcurl4-openssl-dev
apt-get install -y libmhash2 libmhash-dev libpq-dev libpq5 locales
echo "============update apt source file and update system end================="

echo "==================compile & install libiconv start======================="
cd $cur_dir
tar zxf $libiconv_tar_gz_name
cd $libiconv_source_dir_name
./configure --prefix=/usr/local
make && make install
echo "===================compile & install libiconv end========================"

echo "============================mysql install================================"
cd $cur_dir
/usr/sbin/groupadd mysql
/usr/sbin/useradd -g mysql mysql
if [ ! -d $mysql_data_dir ]; then
    mkdir -p $mysql_data_dir
fi
chown -R mysql:mysql $mysql_data_dir

tar zxf $mysql_tar_gz_name
cd $mysql_source_dir_name
./configure --prefix=$mysql_dir --enable-assembler --with-extra-charsets=complex --enable-thread-safe-client --with-big-tables --with-readline --with-ssl --with-embedded-server --enable-local-infile --with-plugins=innobase
make && make install
chmod +w $mysql_dir
chown -R mysql:mysql $mysql_dir
cp support-files/my-medium.cnf $mysql_dir/my.cnf
sed -i 's/skip-federated/#skip-federated/g' $mysql_dir/my.cnf
$mysql_dir/bin/mysql_install_db --basedir=$mysql_dir --datadir=$mysql_data_dir --user=mysql

cp $mysql_dir/share/mysql/mysql.server /etc/init.d/mysqld

es_mysql_dir=$(echo $mysql_dir | sed 's/\//\\\//g')
es_mysql_data_dir=$(echo $mysql_data_dir | sed 's/\//\\\//g')
sed -i 's/^basedir=$/basedir='$es_mysql_dir'/' /etc/init.d/mysqld
sed -i 's/^datadir=$/datadir='$es_mysql_data_dir'/' /etc/init.d/mysqld

chmod 755 /etc/init.d/mysqld
chkconfig --level 345 mysqld on
echo $mysql_dir"/lib/mysql" >> /etc/ld.so.conf
echo "/usr/local/lib" >> /etc/ld.so.conf
ldconfig
ln -s $mysql_dir/lib/mysql /usr/lib/mysql
ln -s $mysql_dir/include/mysql /usr/include/mysql
/etc/init.d/mysqld start
$mysql_dir/bin/mysqladmin -u root password 123456
/etc/init.d/mysqld restart
/etc/init.d/mysqld stop
#chkconfig mysql-ndb off
#chkconfig mysql-ndb-mgm off
echo "============================mysql intall finished========================"

echo "===============================php install==============================="
cd $cur_dir
tar zxf $php_tar_gz_name
gzip -cd $php_fpm_tar_gz_name | patch -d $php_source_dir_name -p1
cd $php_source_dir_name
./configure --prefix=$php_dir --with-config-file-path=$php_dir/etc --with-mysql=$mysql_dir --with-mysqli=$mysql_dir/bin/mysql_config --with-iconv-dir=/usr/local --with-freetype-dir --with-jpeg-dir --with-png-dir --with-zlib --with-libxml-dir=/usr --enable-xml --disable-rpath --enable-discard-path --enable-safe-mode --enable-bcmath --enable-shmop --enable-sysvsem --enable-inline-optimization --with-curl --with-curlwrappers --enable-mbregex --enable-fastcgi --enable-fpm --enable-force-cgi-redirect --enable-mbstring --with-mcrypt --with-gd --enable-gd-native-ttf --with-openssl --with-mhash --enable-pcntl --enable-sockets
make ZEND_EXTRA_LIBS='-liconv'
make install
cp php.ini-dist $php_dir/etc/php.ini

cd $cur_dir
tar zxf $pecl_memcache_tar_gz_name
cd $pecl_memcache_source_dir_name
$php_dir/bin/phpize
./configure --with-php-config=$php_dir/bin/php-config
make && make install

cd $cur_dir
tar zxf $PDO_MYSQL_tar_gz_name
cd $PDO_MYSQL_source_dir_name
$php_dir/bin/phpize
./configure --with-php-config=$php_dir/bin/php-config --with-pdo-mysql=$mysql_dir
make
make install

sed -i 's#extension_dir = "./"#extension_dir = "'$php_dir'/lib/php/extensions/no-debug-non-zts-20060613/"\nextension = "memcache.so"\nextension = "pdo_mysql.so"\n#' $php_dir/etc/php.ini
sed -i 's#output_buffering = Off#output_buffering = On#' $php_dir/etc/php.ini
sed -i 's/post_max_size = 8M/post_max_size = 50M/g' $php_dir/etc/php.ini
sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 50M/g' $php_dir/etc/php.ini
sed -i 's/;date.timezone =/date.timezone = PRC/g' $php_dir/etc/php.ini


#if [ `uname -m` = 'x86_64' ]; then
#        tar zxf ZendOptimizer-3.3.9-linux-glibc23-x86_64.tar.gz
#    mkdir -p /usr/local/zend/
#    cp ZendOptimizer-3.3.9-linux-glibc23-x86_64/data/5_2_x_comp/ZendOptimizer.so /usr/local/zend/
#else
#    tar zxf ZendOptimizer-3.3.9-linux-glibc23-i386.tar.gz
#    mkdir -p /usr/local/zend/
#    cp ZendOptimizer-3.3.9-linux-glibc23-i386/data/5_2_x_comp/ZendOptimizer.so /usr/local/zend/
#fi

#cat >>/usr/local/php/etc/php.ini<<EOF
#[Zend Optimizer]
#zend_optimizer.optimization_level=1
#zend_extension="/usr/local/zend/ZendOptimizer.so"
#EOF

/usr/sbin/groupadd www
/usr/sbin/useradd -g www www
if [ ! -d $web_dir ]; then
    mkdir -p $web_dir
fi
chown -R www:www $web_dir

if [ ! -d $log_dir ]; then
    mkdir -p $log_dir
fi
chown -R www:www $log_dir

cd $cur_dir
rm -f $php_dir/etc/php-fpm.conf
cp -f conf/php-fpm.conf $php_dir/etc/php-fpm.conf

echo "===========================php install finished=========================="

echo "=============================nginx install==============================="
cd $cur_dir
tar zxf $nginx_tar_gz_name
cd $nginx_source_dir_name
./configure --user=www --group=www --prefix=$nginx_dir --with-http_stub_status_module --with-http_ssl_module --http-log-path=$log_dir/access.log --error-log-path=$log_dir/error.log
make && make install

rm -f $nginx_dir/conf/nginx.conf
cd $cur_dir
cp conf/nginx.conf $nginx_dir/conf/nginx.conf
sed -i 's/localhost/'$domain'/g' $nginx_dir/conf/nginx.conf

rm -f $nginx_dir/conf/fcgi.conf
cp conf/fcgi.conf $nginx_dir/conf/fcgi.conf

echo "=========================nginx install finished=========================="

cat >$web_dir/phpinfo.php<<eof
<?
phpinfo();
?>
eof

#echo "=========================phpMyAdmin install============================="
##phpmyadmin
#tar zxf phpmyadmin.tar.gz
#mv phpmyadmin $web_dir
#echo "====================phpMyAdmin install finished========================="

echo "==================add nginx and php-fpm on startup======================="
echo "ulimit -SHn 51200" >> /etc/rc.local
echo $php_dir"/sbin/php-fpm start" >> /etc/rc.local
echo "$nginx_dir/sbin/nginx" >> /etc/rc.local

echo "kernel.shmmax = 134217728" >> /etc/sysctl.conf
echo "net.ipv4.tcp_fin_timeout = 30" >> /etc/sysctl.conf
echo "net.ipv4.tcp_keepalive_time = 300" >> /etc/sysctl.conf
echo "net.ipv4.tcp_syncookies = 1" >> /etc/sysctl.conf
echo "net.ipv4.tcp_tw_reuse = 1" >> /etc/sysctl.conf
echo "net.ipv4.tcp_tw_recycle = 1" >> /etc/sysctl.conf
echo "net.ipv4.ip_local_port_range = 5000 65000" >> /etc/sysctl.conf
/sbin/sysctl -p
echo "==============add nginx and php-fpm on startup finished=================="

#set timezone
cp -f /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

/etc/init.d/mysqld start
$php_dir/sbin/php-fpm start
$nginx_dir/sbin/nginx

clear
echo "========================================================================="
echo "  Wiznmp v0.1 for Ubuntu"
echo "  Author: lostsnow (lostsnow@gmail.com)"
echo "========================================================================="
echo ""
echo "For more information please visit http://www.lsproc.com/blog/"
echo ""
echo "default mysql root password: 123456"
echo "phpinfo test: http://"$domain"/phpinfo.php"
#echo "phpMyAdmin test: http://"$domain"/phpmyadmin"

echo "The path of some dirs:"
echo "  mysql dir:        "$mysql_dir
echo "  php dir:          "$php_dir
echo "  nginx dir:        "$nginx_dir
echo "  memcached dir     "$memcached_dir
echo "  web dir           "$web_dir
echo ""
echo "========================================================================="
fi
#netstat -ntl