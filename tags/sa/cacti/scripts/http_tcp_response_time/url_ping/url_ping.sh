#!/bin/bash

###############
# Ping an url #
##############
LC_ALL="C"
CURL=`which curl`

if [ "$1" = "" ] ; then
        echo "usage: url_ping.sh url"
        echo "  url like http://localhost"
        exit 1
fi
curl --connect-timeout 20 --max-time 30 $1 --write-out "lookup:%{time_namelookup} connect:%{time_connect} 1bit:%{time_starttransfer} total:%{time_total}" -s -S  -o /dev/null | sed "s/,/\./g"

