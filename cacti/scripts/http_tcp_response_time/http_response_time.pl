#! /usr/bin/perl -w

#====================================================================
# What's this ?
#====================================================================
# Script designed for cacti [ http://www.cacti.net ]
# Gives the time to do a HTTP connection
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
use Net::HTTP;
use Getopt::Std;
use Time::HiRes qw(gettimeofday);


#====================================================================
# Option
#====================================================================
my $host = $ARGV[0];
#my ($host, $port) = &options;

#====================================================================
# options() subroutine
#====================================================================
sub options {
        # Init Options Hash Table
        my %opts;
        getopt('hp',\%opts);
        &usage unless exists $opts{"h"};

        return ($opts{"h"}, $opts{"p"});
}

#====================================================================
# usage() subroutine
#====================================================================
sub usage {
	print STDERR "Usage: $0 -h host\n";
        print STDERR "Default values are :\n";
	print STDERR "\tport: 80\n";
	exit 1;
}

#====================================================================
# Connection to HTTP monitor
#====================================================================
my ($t0, $startTime);

$startTime = gettimeofday();

my $s = Net::HTTP->new(Host => $host) || die $@;
$s->write_request(GET => "/", 'User-Agent' => "Mozilla/5.0");
my($code, $mess, %h) = $s->read_response_headers;

$t0 = gettimeofday() - $startTime,

#====================================================================
# Print results Time
#====================================================================
#print "avg:$t0";
printf ("avg:%.2f", $t0*1000);

#====================================================================
# Exit
#====================================================================
exit 0;
