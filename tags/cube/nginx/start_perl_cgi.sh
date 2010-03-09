#!/bin/bash

#set -x

dir=/usr/local/nginx

stop ()
{
    #pkill  -f  $dir/perl-fcgi.pl
    kill $(cat $dir/logs/perl-fcgi.pid)
    rm $dir/logs/perl-fcgi.pid 2>/dev/null
    rm $dir/logs/perl-fcgi.sock 2>/dev/null
    echo "stop perl-fcgi done"
}

start ()
{
    rm $dir/now_start_perl_fcgi.sh 2>/dev/null
    chown nobody.root $dir/logs
    #echo "$dir/perl-fcgi.pl -l $dir/logs/perl-fcgi.log -pid $dir/logs/perl-fcgi.pid -S $dir/logs/perl-fcgi.sock" >>$dir/now_start_perl_fcgi.sh
    #echo "$dir/perl-fcgi.pl -l $dir/logs/perl-fcgi.log -pid $dir/logs/perl-fcgi.pid -S /tmp/perl-fcgi.sock -verbose" >>$dir/now_start_perl_fcgi.sh
    echo "$dir/perl-fcgi.pl -l $dir/logs/perl-fcgi.log -pid $dir/logs/perl-fcgi.pid -S /tmp/perl-fcgi.sock" >>$dir/now_start_perl_fcgi.sh
    chown nobody.nobody $dir/now_start_perl_fcgi.sh
    chmod u+x $dir/now_start_perl_fcgi.sh
    sudo -u nobody $dir/now_start_perl_fcgi.sh
    chmod 777 /tmp/perl-fcgi.sock
    echo "start perl-fcgi done"
}

case $1 in

stop)
stop
;;

start)
start
;;

restart)
stop
start
;;

esac
