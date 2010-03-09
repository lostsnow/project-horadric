#!/usr/bin/perl -w
#====================================================================
# What's this ?
#====================================================================
# Script designed for cacti [ http://www.cacti.net ]
# Gives the time to do a TCP connection
#
# Copyright (C) 2005 Francois LACROIX
# Copyright (C) 2005 UPERTO
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
#====================================================================

#====================================================================
# Modules
#====================================================================
use strict;
use Socket;
use Time::HiRes qw(gettimeofday);

#====================================================================
# Option
#====================================================================


#====================================================================
# usage() subroutine
#====================================================================
sub usage {
        print STDERR "Usage: $0 [host] [port]\n";
        exit 1;
}

#====================================================================
# Connection to TCP monitor
#====================================================================

my ($remote,$port, $iaddr, $paddr, $proto);

$remote = $ARGV[0];
$port = $ARGV[1];
#    $remote  = '10.0.0.1';
#    $port    = 48800;  

if ($port =~ /\D/) { $port = getservbyname($port, 'tcp') }
die "No port" unless $port;
$iaddr   = inet_aton($remote)               || die "no host: $remote";
$paddr   = sockaddr_in($port, $iaddr);

$proto   = getprotobyname('tcp');
socket(SOCK, PF_INET, SOCK_STREAM, $proto)  || die "socket: $!";

my ($t0, $t1, $startTime);

$startTime = gettimeofday();

connect(SOCK, $paddr)    || die "connect: $!";

$t0 = gettimeofday() - $startTime;

#print "avg:$t0";

close (SOCK) || die "close: $!";

#====================================================================
# Print results Time
#====================================================================
print "avg:$t0";

#====================================================================
# Exit
#====================================================================
exit 0;

