#!/bin/bash

function msg_exit()
{
    echo $1;
    exit 0;
}
# Check if user is root
if [ $(id -u) != "0" ]; then
    msg_exit "Error: You must be root to run this script, please use root to install wiznpm"
fi

# remove aliases
unalias cp
unalias rm
unalias mv

echo "===========================OS determining================================"
DIST='unknown'
RELEASE='unknown'
VERSION='unknown'
MAJORVERSION='unknown'
if lsb_release -i -s | tr -d '\n' | grep -q '^RedHatEnterprise'; then
    DIST='rhel'
    RELEASE=`lsb_release -c | awk '{print $2}' | tr -d '\n'`
    VERSION=`lsb_release -r | awk '{print $2}' | tr -d '\n'`
    if echo $VERSION | grep -q '^5'; then
        MAJORVERSION=5
    elif echo $VERSION | grep -q '^4'; then
        MAJORVERSION=4
    else
        msg_exit "UNKNOWN ${DIST} VERSION"
    fi

elif [ `lsb_release -i -s | tr -d '\n'` == 'CentOS' ]; then
    DIST='centos'
    RELEASE=`lsb_release -c | awk '{print $2}' | tr -d '\n'`
    VERSION=`lsb_release -r | awk '{print $2}' | tr -d '\n'`
    if echo $VERSION | grep -q '^5'; then
        MAJORVERSION=5
    elif echo $VERSION | grep -q '^4'; then
        MAJORVERSION=4
    else
        msg_exit "UNKNOWN ${DIST} VERSION"
    fi

elif [ `lsb_release -i -s | tr -d '\n'` == 'Ubuntu' ]; then
    DIST='ubuntu'
    RELEASE=`lsb_release -c | awk '{print $2}' | tr -d '\n'`
#    case ${RELEASE} in
##        'karmic') ;;
#        'jaunty') ;;
#        'intrepid') ;;
#        'hardy') ;;
#        'gutsy') ;;
#        'feisty') ;;
#        'edgy') ;;
#        * ) msg_exit '${DIST} ${RELEASE} is not suported';;
#    esac
    VERSION=`lsb_release -r | awk '{print $2}' | tr -d '\n'`

elif [ -e /etc/debian_version ]; then
    DIST='debian'
    RELEASE=`lsb_release -c | awk '{print $2}' | tr -d '\n'`
#    case ${RELEASE} in
#        'sarge') ;;
#        'etch') ;;
#        'lenny') ;;
#        'squeeze') ;;
#        * ) msg_exit '${DIST} ${RELEASE} is not suported';;
#    esac

elif [ -e /etc/fedora-release ]; then
    DIST='fedora'

elif [ -e /etc/SuSE-release ]; then
    DIST='opensuse'

elif [ -e /etc/gentoo-release ]; then
    DIST='gentoo'

elif [ -e /etc/slackware-version ]; then
    DIST='slackware'
    msg_exit 'Slackware is not suported yet'
else
    msg_exit 'Unknown Linux ditribution: not suported'
fi

#---------------------config start-------------------------
nginx_version="0.7.65"
php_version="5.2.13"
mysql_version="5.1.44"
php_fpm_version="0.5.13"
libiconv_version="1.13.1"
libmcrypt_version="2.5.8"
mcrypt_version="2.6.8"
memcached_version="1.4.4"
pecl_memcache_version="2.2.5"
apc_version="3.1.3p1"
mhash_version="0.9.9.9"
pcre_version="8.01"
#eaccelerator_version="0.9.5.3"
PDO_MYSQL_version="1.0.2"
python_version="2.5.5"
libevent_major_version="1.4"
libevent_version=$libevent_major_version".13-stable"

nginx_tar_gz_name="nginx-"$nginx_version".tar.gz"
php_tar_gz_name="php-"$php_version".tar.gz"
mysql_tar_gz_name="mysql-"$mysql_version".tar.gz"
php_fpm_tar_gz_name="php-"$php_version"-fpm-"$php_fpm_version".diff.gz"
libiconv_tar_gz_name="libiconv-"$libiconv_version".tar.gz"
libmcrypt_tar_gz_name="libmcrypt-"$libmcrypt_version".tar.gz"
mcrypt_tar_gz_name="mcrypt-"$mcrypt_version".tar.gz"
memcached_tar_gz_name="memcached-"$memcached_version".tar.gz"
pecl_memcache_tar_gz_name="memcache-"$pecl_memcache_version".tgz"
apc_tar_gz_name="APC-"$apc_version".tgz"
mhash_tar_gz_name="mhash-"$mhash_version".tar.gz"
pcre_tar_gz_name="pcre-"$pcre_version".tar.gz"
#eaccelerator_tar_gz_name="eaccelerator-"$eaccelerator_version".tar.bz2"
PDO_MYSQL_tar_gz_name="PDO_MYSQL-"$PDO_MYSQL_version".tgz"
python_tar_gz_name="Python-"$python_version".tgz"
libevent_tar_gz_name="libevent-"$libevent_version".tar.gz"

nginx_source_dir_name="nginx-"$nginx_version
php_source_dir_name="php-"$php_version
mysql_source_dir_name="mysql-"$mysql_version
php_fpm_source_dir_name="php-"$php_version"-fpm-"$php_fpm_version
libiconv_source_dir_name="libiconv-"$libiconv_version
libmcrypt_source_dir_name="libmcrypt-"$libmcrypt_version
mcrypt_source_dir_name="mcrypt-"$mcrypt_version
memcached_source_dir_name="memcached-"$memcached_version
pecl_memcache_source_dir_name="memcache-"$pecl_memcache_version
apc_source_dir_name="APC-"$apc_version
mhash_source_dir_name="mhash-"$mhash_version
pcre_source_dir_name="pcre-"$pcre_version
#eaccelerator_source_dir_name="eaccelerator-"$eaccelerator_version
PDO_MYSQL_source_dir_name="PDO_MYSQL-"$PDO_MYSQL_version
python_source_dir_name="Python-"$python_version
libevent_source_dir_name="libevent-"$libevent_version

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
apc_download_url=$base_download_url$apc_tar_gz_name
mhash_download_url=$base_download_url$mhash_tar_gz_name
pcre_download_url=$base_download_url$pcre_tar_gz_name
#eaccelerator_download_url=$base_download_url$eaccelerator_tar_gz_name
PDO_MYSQL_download_url=$base_download_url$PDO_MYSQL_tar_gz_name
python_download_url=$base_download_url$python_tar_gz_name
libevent_download_url=$base_download_url$libevent_tar_gz_name

nginx_dir="/usr/local/nginx"
php_dir="/usr/local/php"
python_dir="/usr/local"
mysql_dir="/usr/local/mysql"
mysql_data_dir="/var/lib/mysql"
memcached_dir="/usr/local/memcached"
libevent_dir="/usr/local/libevent"
web_dir="/var/www"
log_dir="/var/log/nginx"
install_python="Yes"

# none, sohu, 163
yum_source=none

nginx_worker=8
fcgi_children=128

#---------------------config end---------------------------

clear
echo "========================================================================="
echo "  Wiznmp v0.1 for CentOS/RHEL etc."
echo "  Author: lostsnow (lostsnow@gmail.com)"
echo "========================================================================="
echo "A tool to auto-compile & install Nginx+MySQL+PHP on Linux"
echo "For more information please visit http://www.lsproc.com/blog/"
echo ""
echo "Your operation system is: ${DIST} ${VERSION}"
echo ""
echo "The path of some dirs:"
echo "  python dir:       "$python_dir
echo "  mysql dir:        "$mysql_dir
echo "  php dir:          "$php_dir
echo "  nginx dir:        "$nginx_dir
echo "  memcached dir     "$memcached_dir
echo "  web dir           "$web_dir
echo ""
echo "========================================================================="
cur_dir=$(pwd)
src_dir=$cur_dir/src
conf_dir=$cur_dir/conf

if [ ! -d $src_dir ]; then
    mkdir -p $src_dir
fi

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

    echo ""
    echo "if you want to install mysql server (if no you will only install mysql client) ?"
    select install_mysql_server in "Yes" "No"; do
    break
    done

    echo ""
    echo "if you want to install memcached?"
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
cd $src_dir
if [ "$sources_from" = "Download from Internet." ]; then
    rm -rf $nginx_tar_gz_name
    rm -rf $nginx_source_dir_name
    wget -c $nginx_download_url
    rm -rf $php_tar_gz_name
    rm -rf $php_source_dir_name
    wget -c $php_download_url
    rm -rf $mysql_tar_gz_name
    rm -rf $mysql_source_dir_name
    wget -c $mysql_download_url
    rm -rf $php_fpm_tar_gz_name
    rm -rf $php_fpm_source_dir_name
    wget -c $php_fpm_download_url
    rm -rf $libiconv_tar_gz_name
    rm -rf $libiconv_source_dir_name
    wget -c $libiconv_download_url
    rm -rf $libmcrypt_tar_gz_name
    rm -rf $libmcrypt_source_dir_name
    wget -c $libmcrypt_download_url
    rm -rf $mcrypt_tar_gz_name
    rm -rf $mcrypt_source_dir_name
    wget -c $mcrypt_download_url
    rm -rf $pecl_memcache_tar_gz_name
    rm -rf $pecl_memcache_source_dir_name
    wget -c $pecl_memcache_download_url
    rm -rf $apc_tar_gz_name
    rm -rf $apc_source_dir_name
    wget -c $apc_download_url
    rm -rf $mhash_tar_gz_name
    rm -rf $mhash_source_dir_name
    wget -c $mhash_download_url
    rm -rf $pcre_tar_gz_name
    rm -rf $pcre_source_dir_name
    wget -c $pcre_download_url
#    rm -rf $eaccelerator_tar_gz_name
#    rm -rf $eaccelerator_source_dir_name
#    wget -c $eaccelerator_download_url
    rm -rf $PDO_MYSQL_tar_gz_name
    rm -rf $PDO_MYSQL_source_dir_name
    wget -c $PDO_MYSQL_download_url
#    rm -rf $yum_source
#    wget -c $yum_source_url
fi

if [ "$install_python" = "Yes" ]; then
    if [ "$sources_from" = "Download from Internet." ]; then
        rm -f $python_tar_gz_name
        wget -c $python_download_url
    fi
fi

if [ "$install_memcached" = "Yes" ]; then
    if [ "$sources_from" = "Download from Internet." ]; then
        rm -rf $libevent_tar_gz_name
        rm -rf $libevent_source_dir_name
        wget -c $libevent_download_url
        rm -rf $memcached_tar_gz_name
        rm -rf $memcached_source_dir_name
        wget -c $memcached_download_url
    fi
fi

echo "checking files"
if [ -s $nginx_tar_gz_name ]; then
    echo "$nginx_tar_gz_name [found]"
    else
    echo ""
    msg_exit "Error: $nginx_tar_gz_name not found!!!"
fi

if [ -s $php_tar_gz_name ]; then
    echo "$php_tar_gz_name [found]"
    else
    echo ""
    msg_exit "Error: $php_tar_gz_name not found!!!"
fi

if [ -s $mysql_tar_gz_name ]; then
    echo "$mysql_tar_gz_name [found]"
    else
    echo ""
    msg_exit "Error: $mysql_tar_gz_name not found!!!"
fi

if [ -s $php_fpm_tar_gz_name ]; then
    echo "$php_fpm_tar_gz_name [found]"
    else
    echo ""
    msg_exit "Error: $php_fpm_tar_gz_name not found!!!"
fi

if [ -s $libiconv_tar_gz_name ]; then
    echo "$libiconv_tar_gz_name [found]"
    else
    echo ""
    msg_exit "Error: $libiconv_tar_gz_name not found!!!"
fi

if [ -s $libmcrypt_tar_gz_name ]; then
    echo "$libmcrypt_tar_gz_name [found]"
    else
    echo ""
    msg_exit "Error: $libmcrypt_tar_gz_name not found!!!"
fi

if [ -s $mcrypt_tar_gz_name ]; then
    echo "$mcrypt_tar_gz_name [found]"
    else
    echo ""
    msg_exit "Error: $mcrypt_tar_gz_name not found!!!"
fi

if [ -s $pecl_memcache_tar_gz_name ]; then
    echo "$pecl_memcache_tar_gz_name [found]"
    else
    echo ""
    msg_exit "Error: $pecl_memcache_tar_gz_name not found!!!"
fi

if [ -s $apc_tar_gz_name ]; then
    echo "$apc_tar_gz_name [found]"
    else
    echo ""
    msg_exit "Error: $apc_tar_gz_name not found!!!"
fi

if [ -s $mhash_tar_gz_name ]; then
    echo "$mhash_tar_gz_name [found]"
    else
    echo ""
    msg_exit "Error: $mhash_tar_gz_name not found!!!"
fi

if [ -s $pcre_tar_gz_name ]; then
    echo "$pcre_tar_gz_name [found]"
    else
    echo ""
    msg_exit "Error: $pcre_tar_gz_name not found!!!"
fi

#if [ -s $eaccelerator_tar_gz_name ]; then
#  echo "$eaccelerator_tar_gz_name [found]"
#  else
#  echo ""
#  msg_exit "Error: $eaccelerator_tar_gz_name not found!!!"
#fi

if [ -s $PDO_MYSQL_tar_gz_name ]; then
    echo "$PDO_MYSQL_tar_gz_name [found]"
    else
    echo ""
    msg_exit "Error: $PDO_MYSQL_tar_gz_name not found!!!"
fi

#if [ -s $yum_source ]; then
#    echo "$yum_source [found]"
#    else
#    echo ""
#    msg_exit "Error: $yum_source not found!!!"
#fi
if [ "$install_python" = "Yes" ]; then
    if [ -s $python_tar_gz_name ]; then
        echo "$python_tar_gz_name [found]"
        else
        echo ""
        msg_exit "Error: $python_tar_gz_name not found!!!"
    fi
fi

if [ "$install_memcached" = "Yes" ]; then
    if [ -s $libevent_tar_gz_name ]; then
        echo "$libevent_tar_gz_name [found]"
        else
        echo ""
        msg_exit "Error: $libevent_tar_gz_name not found!!!"
    fi
    if [ -s $memcached_tar_gz_name ]; then
        echo "$memcached_tar_gz_name [found]"
        else
        echo ""
        msg_exit "Error: $memcached_tar_gz_name not found!!!"
    fi
fi
echo "====================download and check files end========================="

echo "===========update yum source file and update system start================"
cd $cur_dir
if [ ${DIST} == 'centos' ]; then
    if [ ${MAJORVERSION} == 5 ]; then
        if [ ${yum_source} == 'none' ]; then
            echo "use default yum repos file."
        elif [ ! -f $conf_dir/CentOS-Base-${yum_source}.repo ]; then
            echo "use default yum repos file."
        else
            yum_bak_name="CentOS-Base.repo."`date '+%Y%m%d%H%M%S'`
            cp -f /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/$yum_bak_name
            cp -f $conf_dir/CentOS-Base-${yum_source}.repo /etc/yum.repos.d/CentOS-Base.repo
        fi
    fi
fi

#yum -y remove httpd
yum -y update
yum -y install patch make gcc gcc-c++
yum -y install libtool libtool-libs autoconf
yum -y install libjpeg libjpeg-devel libpng libpng-devel
yum -y install freetype freetype-devel libxml2 libxml2-devel zlib zlib-devel
yum -y install glibc glibc-devel glib2 glib2-devel bzip2 bzip2-devel
yum -y install ncurses ncurses-devel curl curl-devel e2fsprogs e2fsprogs-devel
yum -y install krb5 krb5-devel libidn libidn-devel
yum -y install openssl openssl-devel
echo "============update yum source file and update system end================="

echo "=============compile & install required libraries start=================="
cd $src_dir
tar zxf $libiconv_tar_gz_name
cd $libiconv_source_dir_name
./configure --prefix=/usr/local #2> err |tee log
make && make install

cd $src_dir
tar zxf $libmcrypt_tar_gz_name
cd $libmcrypt_source_dir_name
./configure
make && make install
/sbin/ldconfig
cd libltdl/
./configure --enable-ltdl-install
make && make install

cd $src_dir
tar zxf $mhash_tar_gz_name
cd $mhash_source_dir_name
./configure
make && make install

if [ `uname -m` = 'x86_64' ]; then
    ln -s /usr/local/lib/libmcrypt.la /usr/lib64/libmcrypt.la
    ln -s /usr/local/lib/libmcrypt.so /usr/lib64/libmcrypt.so
    ln -s /usr/local/lib/libmcrypt.so.4 /usr/lib64/libmcrypt.so.4
    ln -s /usr/local/lib/libmcrypt.so.4.4.8 /usr/lib64/libmcrypt.so.4.4.8
    ln -s /usr/local/lib/libmhash.a /usr/lib64/libmhash.a
    ln -s /usr/local/lib/libmhash.la /usr/lib64/libmhash.la
    ln -s /usr/local/lib/libmhash.so /usr/lib64/libmhash.so
    ln -s /usr/local/lib/libmhash.so.2 /usr/lib64/libmhash.so.2
    ln -s /usr/local/lib/libmhash.so.2.0.1 /usr/lib64/libmhash.so.2.0.1
else
    ln -s /usr/local/lib/libmcrypt.la /usr/lib/libmcrypt.la
    ln -s /usr/local/lib/libmcrypt.so /usr/lib/libmcrypt.so
    ln -s /usr/local/lib/libmcrypt.so.4 /usr/lib/libmcrypt.so.4
    ln -s /usr/local/lib/libmcrypt.so.4.4.8 /usr/lib/libmcrypt.so.4.4.8
    ln -s /usr/local/lib/libmhash.a /usr/lib/libmhash.a
    ln -s /usr/local/lib/libmhash.la /usr/lib/libmhash.la
    ln -s /usr/local/lib/libmhash.so /usr/lib/libmhash.so
    ln -s /usr/local/lib/libmhash.so.2 /usr/lib/libmhash.so.2
    ln -s /usr/local/lib/libmhash.so.2.0.1 /usr/lib/libmhash.so.2.0.1
fi

cd $src_dir
tar zxf $mcrypt_tar_gz_name
cd $mcrypt_source_dir_name
./configure
make && make install

echo "==============compile & install required libraries end==================="

if [ "$install_python" = "Yes" ]; then
    echo "===========================python install================================"
    cd $src_dir
    tar zxf $python_tar_gz_name
    cd $python_source_dir_name
    ./configure --prefix=$python_dir
    make && make install
    echo "=======================python install finished==========================="
fi

echo "===================generate configuration files start===================="
cd $cur_dir
if [ "$install_python" = "Yes" ]; then
    python_bin_dir=$python_dir/bin
else
    python_bin_dir=/usr/bin
fi

$python_bin_dir/python ez_setup.py
$python_bin_dir/python $python_bin_dir/easy_install mako

$python_bin_dir/python confnginx.py -n $nginx_dir -l $log_dir -w $web_dir -d $domain -k $nginx_worker
ngx_conf_dir=$cur_dir/ngx_conf_$domain

$python_bin_dir/python conffpm.py -p $php_dir -l $log_dir -c $fcgi_children
fpm_conf_dir=$cur_dir/fpm_conf
echo "====================generate configuration files end====================="

echo "============================mysql install================================"
cd $src_dir
/usr/sbin/groupadd mysql
/usr/sbin/useradd -g mysql mysql
if [ ! -d $mysql_data_dir ]; then
    mkdir -p $mysql_data_dir
fi
chown -R mysql:mysql $mysql_data_dir

tar zxf $mysql_tar_gz_name
cd $mysql_source_dir_name
./configure --prefix=$mysql_dir --enable-assembler --with-extra-charsets=complex --enable-thread-safe-client --with-big-tables --with-readline --with-ssl --with-embedded-server --enable-local-infile --with-plugins=innobase --with-pic --with-fast-mutexes --with-client-ldflags=-static --with-mysqld-ldflags=-static --with-partition --with-innodb --without-ndbcluster --with-archive-storage-engine --with-blackhole-storage-engine --with-csv-storage-engine --without-example-storage-engine --with-federated-storage-engine
make && make install
chmod +w $mysql_dir
chown -R mysql:mysql $mysql_dir
cp -f support-files/my-medium.cnf $mysql_dir/my.cnf
sed -i 's/skip-federated/#skip-federated/g' $mysql_dir/my.cnf

if [ "$install_mysql_server" = "Yes" ]; then
    $mysql_dir/bin/mysql_install_db --basedir=$mysql_dir --datadir=$mysql_data_dir --user=mysql

    cp -f $mysql_dir/share/mysql/mysql.server /etc/init.d/mysqld

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
fi
echo "============================mysql intall finished========================"

if [ "$install_memcached" = "Yes" ]; then
echo "===========================memcached install============================="
cd $src_dir
tar zxf $libevent_tar_gz_name
cd $libevent_source_dir_name
./configure --prefix=$libevent_dir
make && make install

libevent_so=libevent-$libevent_major_version.so.2
if [ `uname -m` = 'x86_64' ]; then
ln -s $libevent_dir/lib/$libevent_so /usr/lib64/$libevent_so
else
ln -s $libevent_dir/lib/$libevent_so /usr/lib/$libevent_so
fi

cd $src_dir
tar zxf $memcached_tar_gz_name
cd $memcached_source_dir_name
if [ `uname -m` = 'x86_64' ]; then
./configure --prefix=$memcached_dir --with-libevent=$libevent_dir --enable-64bit
else
./configure --prefix=$memcached_dir --with-libevent=$libevent_dir
fi
make && make install
echo "========================memcached intall finished========================"
fi

echo "===============================php install==============================="
#rhel 4 ?
#ln -s /usr/lib/libjpeg.so.62 /usr/lib/libjpeg.so
#ln -s /usr/lib/libpng.so.3 /usr/lib/libpng.so
cd $src_dir
tar zxf $php_tar_gz_name
gzip -cd $php_fpm_tar_gz_name | patch -d $php_source_dir_name -p1
cd $php_source_dir_name
./configure --prefix=$php_dir --with-config-file-path=$php_dir/etc --with-mysql=$mysql_dir --with-mysqli=$mysql_dir/bin/mysql_config --with-iconv-dir=/usr/local --with-freetype-dir --with-jpeg-dir --with-png-dir --with-zlib --with-libxml-dir=/usr --enable-xml --disable-rpath --enable-discard-path --enable-safe-mode --enable-bcmath --enable-shmop --enable-sysvsem --enable-inline-optimization --with-curl --with-curlwrappers --enable-mbregex --enable-fastcgi --enable-fpm --enable-force-cgi-redirect --enable-mbstring --with-mcrypt --with-gd --enable-gd-native-ttf --with-openssl --with-mhash --enable-pcntl --enable-sockets
make ZEND_EXTRA_LIBS='-liconv'
make install
cp -f php.ini-dist $php_dir/etc/php.ini

cd $src_dir
tar zxf $pecl_memcache_tar_gz_name
cd $pecl_memcache_source_dir_name
$php_dir/bin/phpize
./configure --with-php-config=$php_dir/bin/php-config
make && make install

cd $src_dir
tar zxf $PDO_MYSQL_tar_gz_name
cd $PDO_MYSQL_source_dir_name
$php_dir/bin/phpize
./configure --with-php-config=$php_dir/bin/php-config --with-pdo-mysql=$mysql_dir
make
make install

cd $src_dir
tar zxf $apc_tar_gz_name
cd $apc_source_dir_name
$php_dir/bin/phpize
./configure --with-php-config=$php_dir/bin/php-config
make && make install

sed -i 's#extension_dir = "./"#extension_dir = "'$php_dir'/lib/php/extensions/no-debug-non-zts-20060613/"\nextension = "memcache.so"\nextension = "pdo_mysql.so"\nextension = "apc.so"\n#' $php_dir/etc/php.ini
sed -i 's/post_max_size = 8M/post_max_size = 50M/g' $php_dir/etc/php.ini
sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 50M/g' $php_dir/etc/php.ini
sed -i 's/;date.timezone =/date.timezone = PRC/g' $php_dir/etc/php.ini
#sed -i 's#output_buffering = Off#output_buffering = On#' $php_dir/etc/php.ini

cat >>$php_dir/etc/php.ini<<EOF
[APC]
apc.enabled = 1
apc.cache_by_default = On
apc.enable_cli = off
apc.file_update_protection = 2

apc.ttl = 7200
apc.user_ttl = 7200
apc.gc_ttl = 3600

apc.include_once_override = off
apc.num_files_hint = 1000
apc.optimization = 1

apc.shm_segments = 1
apc.shm_size = 64

apc.slam_defense = 0
apc.max_file_size = 1M
EOF

#if [ `uname -m` = 'x86_64' ]; then
#        tar zxf ZendOptimizer-3.3.9-linux-glibc23-x86_64.tar.gz
#    mkdir -p /usr/local/zend/
#    cp -f ZendOptimizer-3.3.9-linux-glibc23-x86_64/data/5_2_x_comp/ZendOptimizer.so /usr/local/zend/
#else
#    tar zxf ZendOptimizer-3.3.9-linux-glibc23-i386.tar.gz
#    mkdir -p /usr/local/zend/
#    cp -f ZendOptimizer-3.3.9-linux-glibc23-i386/data/5_2_x_comp/ZendOptimizer.so /usr/local/zend/
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
cp -f $fpm_conf_dir/php-fpm.conf $php_dir/etc/php-fpm.conf

echo "===========================php install finished=========================="

echo "=============================nginx install==============================="
cd $src_dir
tar zxf $pcre_tar_gz_name
cd $pcre_source_dir_name
./configure
make && make install

cd $src_dir
tar zxf $nginx_tar_gz_name
cd $nginx_source_dir_name
./configure --user=www --group=www --prefix=$nginx_dir --with-http_stub_status_module --with-http_ssl_module --http-log-path=$log_dir/access.log --error-log-path=$log_dir/error.log
make && make install

cd $cur_dir
rm -f $nginx_dir/conf/nginx.conf
cp -rf $ngx_conf_dir/* $nginx_dir/conf/

rm -f $nginx_dir/conf/fcgi.conf
cp -f $conf_dir/fcgi.conf $nginx_dir/conf/fcgi.conf

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

OUTFILE=/etc/sysctl.conf
(
cat <<'EOF'
# Avoid a smurf attack
net.ipv4.icmp_echo_ignore_broadcasts = 1

# Turn on protection for bad icmp error messages
net.ipv4.icmp_ignore_bogus_error_responses = 1

# Turn on syncookies for SYN flood attack protection
net.ipv4.tcp_syncookies = 1

# Turn on and log spoofed, source routed, and redirect packets
net.ipv4.conf.all.log_martians = 1
net.ipv4.conf.default.log_martians = 1

# No source routed packets here
net.ipv4.conf.all.accept_source_route = 0
net.ipv4.conf.default.accept_source_route = 0

# Turn on reverse path filtering
net.ipv4.conf.all.rp_filter = 1
net.ipv4.conf.default.rp_filter = 1

# Make sure no one can alter the routing tables
net.ipv4.conf.all.accept_redirects = 0
net.ipv4.conf.default.accept_redirects = 0
net.ipv4.conf.all.secure_redirects = 0
net.ipv4.conf.default.secure_redirects = 0

# Don't act as a router
net.ipv4.ip_forward = 0
net.ipv4.conf.all.send_redirects = 0
net.ipv4.conf.default.send_redirects = 0

# Turn on execshild
kernel.exec-shield = 1
#kernel.randomize_va_space = 1

# Tuen IPv6
#net.ipv6.conf.default.router_solicitations = 0
#net.ipv6.conf.default.accept_ra_rtr_pref = 0
#net.ipv6.conf.default.accept_ra_pinfo = 0
#net.ipv6.conf.default.accept_ra_defrtr = 0
#net.ipv6.conf.default.autoconf = 0
#net.ipv6.conf.default.dad_transmits = 0
#net.ipv6.conf.default.max_addresses = 1

# Optimization for port usefor LBs
# Increase system file descriptor limit
fs.file-max = 65535

# Allow for more PIDs (to reduce rollover problems); may break some programs 32768
kernel.pid_max = 65536

# Increase system IP port limits
net.ipv4.ip_local_port_range = 2000 65000

# Increase TCP max buffer size setable using setsockopt()
net.ipv4.tcp_rmem = 4096 87380 8388608
net.ipv4.tcp_wmem = 4096 87380 8388608

# Increase Linux auto tuning TCP buffer limits
# min, default, and max number of bytes to use
# set max to at least 4MB, or higher if you use very high BDP paths
# Tcp Windows etc
net.core.wmem_default = 8388608
net.core.rmem_default = 8388608
net.core.rmem_max = 16777216
net.core.wmem_max = 16777216
net.core.netdev_max_backlog = 32768
net.ipv4.tcp_window_scaling = 1

# other
net.ipv4.tcp_max_syn_backlog = 65536
net.core.somaxconn = 32768

net.ipv4.tcp_timestamps = 0
net.ipv4.tcp_synack_retries = 2
net.ipv4.tcp_syn_retries = 2

net.ipv4.tcp_tw_recycle = 1
net.ipv4.tcp_tw_reuse = 1

net.ipv4.tcp_mem = 94500000 915000000 927000000
net.ipv4.tcp_max_orphans = 3276800
EOF
) >> $OUTFILE

/sbin/sysctl -p
echo "==============add nginx and php-fpm on startup finished=================="

# set timezone
cp -f /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

if [ "$install_mysql_server" = "Yes" ]; then
    /etc/init.d/mysqld start
fi
$php_dir/sbin/php-fpm start
$nginx_dir/sbin/nginx

# start memcached
#if [ "$install_memcached" = "Yes" ]; then
#    $memcached_dir/bin/memcached -d -m 512 -l 127.0.0.1 -p 11211 -u www
#fi

clear
echo "========================================================================="
echo "  Wiznmp v0.1 for CentOS/RHEL etc."
echo "  Author: lostsnow (lostsnow@gmail.com)"
echo "========================================================================="
echo ""
echo "For more information please visit http://www.lsproc.com/blog/"
echo ""
echo "Your operation system is: ${DIST} ${VERSION}"
echo ""
echo "default mysql root password: 123456"
echo "phpinfo test: http://"$domain"/phpinfo.php"
#echo "phpMyAdmin test: http://"$domain"/phpmyadmin"

echo "The path of some dirs:"
echo "  python dir:       "$python_dir
echo "  mysql dir:        "$mysql_dir
echo "  php dir:          "$php_dir
echo "  nginx dir:        "$nginx_dir
echo "  memcached dir     "$memcached_dir
echo "  web dir           "$web_dir
echo ""
echo "========================================================================="
fi
