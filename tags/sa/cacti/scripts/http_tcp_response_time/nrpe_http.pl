#!/usr/bin/perl

$response = `/var/www/html/cacti/scripts/check_http -H $ARGV[0] -f follow -t 60`;
chomp $response;
#($load) = ($response =~ /NOW: Mean:(\d+\|\d)/);
($load) = ($response =~ /time=(\d+\.\d+|\d+\.|\.\d+|\d+)/);
#print "$response\n";
print "$load\n";
