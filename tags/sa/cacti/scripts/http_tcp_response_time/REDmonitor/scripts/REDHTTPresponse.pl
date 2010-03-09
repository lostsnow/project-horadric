#!/usr/bin/perl
use strict;
#use warnings;

use Time::HiRes qw(gettimeofday tv_interval);
use RRDs;
use HTTP::Request;
use HTTP::Date;
use LWP::UserAgent;
use CGI qw(:standard);
use CGI::Carp;
use DBI;

### Site/header/footer and other details

my $ua = LWP::UserAgent->new;
my $site = $ARGV[0]; # Example www.yourgoodtimes.com
my $header = $ARGV[1]; # Example for top header '<!--top header-->'
my $footer = $ARGV[2]; # Example for bottom footer '<!--bottom header-->'
my $mysqllog = $ARGV[3]; # This is to tell the script to either log its results to mysql or not.
my $alert = $ARGV[4]; # This is to tell the script to either alert or not.

### WE don't trust the above completely... so just in case
#$alert = '' unless defined($alert);

### Alert email details

my $smtp='localhost'; # A email sending server.
my $subject='';
my $fromaddr='REDmonitr<Alerts@dodgynet.it>'; # Alert from address.
my $message='';
my $to=$ARGV[5]; # Email address/s you are alerting too.
my $okmessage='We are up'; # Message that gets sent when.	
my $subjectup='Website is down'; # Email alert subject when site comes backup

### Cacti database details

my $dbserver='localhost';
my $database='cacti';
my $dbuser='';
my $dbpassword='';

### Other important things

my $fullsite = "http://" . $site;
my $request = HTTP::Request->new (GET => $fullsite);
my $substarttime = gettimeofday;
my $response = $ua->simple_request($request);
my $subendtime=gettimeofday;
my $subresptime = ($subendtime - $substarttime) * 1000;
my $content;
my $contentlevel;
my $inPage='';
my $errorCount;
my $siteName=$site;

# Define the databaseconnection
my $dsn          = "DBI:mysql:$database:$dbserver";
my $db_user_name = "$dbuser";
my $db_password  = "$dbpassword";
my $dbh          = DBI->connect($dsn, $db_user_name, $db_password);	
my $sth;	

### Email sending function

sub sendmail  {

	###################################################################
	#Sendmail.pm routine below by Milivoj Ivkovic
	###################################################################
	# error codes below for those who bother to check result codes <gr>
	# 1 success
	# -1 $smtphost unknown
	# -2 socket() failed
	# -3 connect() failed
	# -4 service not available
	# -5 unspecified communication error
	# -6 local user $to unknown on host $smtp
	# -7 transmission of message failed
	# -8 argument $to empty
	#
	#  Sample call:
	#
	# &sendmail($from, $reply, $to, $smtp, $subject, $downmessage );
	#
	#  Note that there are several commands for cleaning up possible bad inputs - if you
	#  are hard coding things from a library file, so of those are unnecesssary
	#

	    use Socket;

	    my ($fromaddr, $to, $smtp, $subject, $message) = @_;

	    $to =~ s/[ \t]+/, /g; # pack spaces and add comma
	    $fromaddr =~ s/.*<([^\s]*?)>/$1/; # get from email address
	    $message =~ s/^\./\.\./gm; # handle . as first character
	    $message =~ s/\r\n/\n/g; # handle line ending
	    $message =~ s/\n/\r\n/g;
	    $smtp =~ s/^\s+//g; # remove spaces around $smtp
	    $smtp =~ s/\s+$//g;

	    my $SMTP_SERVER = $smtp;
	    my $SEND_MAIL = "";

	    if (!$to)
	    {
		return(-8);
	    }

	 if ($SMTP_SERVER ne "")
	  {
	    my($proto) = (getprotobyname('tcp'))[2];
	    my($port) = (getservbyname('smtp', 'tcp'))[2];

	    my($smtpaddr) = ($smtp =~ /^(\d{1,3})\.(\d{1,3})\.(\d{1,3})\.(\d{1,3})$/)
		? pack('C4',$1,$2,$3,$4)
		    : (gethostbyname($smtp))[4];

	    if (!defined($smtpaddr))
	    {
		return(-1);
	    }

	    if (!socket(MAIL, AF_INET, SOCK_STREAM, $proto))
	    {
		return(-2);
	    }

	    if (!connect(MAIL, pack('Sna4x8', AF_INET, $port, $smtpaddr)))
	    {
		return(-3);
	    }

	    my($oldfh) = select(MAIL);
	    $| = 1;
	    select($oldfh);

	    $_ = <MAIL>;
	    if (/^[45]/)
	    {
		close(MAIL);
		return(-4);
	    }

	    print MAIL "helo $SMTP_SERVER\r\n";
	    $_ = <MAIL>;
	    if (/^[45]/)
	    {
		close(MAIL);
		return(-5);
	    }

	    print MAIL "mail from: <$fromaddr>\r\n";
	    $_ = <MAIL>;
	    if (/^[45]/)
	    {
		close(MAIL);
		return(-5);
	    }

	    foreach (split(/, /, $to))
	    {
		print MAIL "rcpt to: <$_>\r\n";
		$_ = <MAIL>;
		
		if (/^[45]/)
		{
		    close(MAIL);
		    return(-6);
		}
	    }

	    print MAIL "data\r\n";
	    $_ = <MAIL>;
	    if (/^[45]/)
	    {
		close MAIL;
		return(-5);
	    }

	   }

	  if ($SEND_MAIL ne "")
	   {
	     open (MAIL,"| $SEND_MAIL");
	   }

	    print MAIL "To: $to\n";
	    print MAIL "From: $fromaddr\n";
	    print MAIL "X-Mailer: Perl Powered Socket Mailer\n";
	    print MAIL "Subject: $subject\n\n";
	    print MAIL "$message";
	    print MAIL "\n.\n";

	 if ($SMTP_SERVER ne "")
	  {
	    $_ = <MAIL>;
	    if (/^[45]/)
	    {
		close(MAIL);
		return(-7);
	    }

	    print MAIL "quit\r\n";
	    $_ = <MAIL>;
	  }

	    close(MAIL);
	    return(1);
}

# ContentLevel meanings.
# 2 = Correct Content page is returned perfectly. It looks for a HTML comment containing "top header" and "bottom header",
# to denote a correct page.
# 1 = Page is returned but has incorrect content
# 0 = Represents an Error
# -1 = Represents a failed DNS lookup
	

	sub patternMatch{
	
		########################################################################################
		#
		# Simple function to take in three things to search for in a page, and see if they're
		# there. The page contents should be in $content, the others are labelled according to
		# where they should be
		#
		# NB inPage must exist somewhere in the page, it can be anywhere, not just in the middle
		#
		########################################################################################
		
		my ($header,$footer,$inPage,$content) = @_;

		if(!defined($header) || !defined($footer) || !defined($inPage) || !defined($content)){

			return 0;
		}

		$_ = $content;

		if($header ne ''){
			return 0 unless (m/^(\W*$header)/s);
		}

		if($footer ne ''){
			return 0 unless (m/($footer\W*)$/s);
		}

		if($inPage ne ''){
			return 0 unless (m/$inPage/s)
		}

		# If you got this far without it failing, it must be okay :)

		return 1;
	}

if ($response->is_success) {
	$content = $response->content;
	if (	&patternMatch($header,$footer,$inPage,$content)	){
		$contentlevel = 2;
	}else{		
		$contentlevel = 1;
	}
} elsif ($response->is_error) {
	$content = $response->error_as_HTML;
	if($content =~m/Timeout/){
		#print "timeout for $site\n";
		$contentlevel = 0;
	}
	if($content =~m/hostname/){
		#print "bad dns for $site\n";
		$contentlevel = -1;
	}
}

#unknown error shouldn't happen

if(!defined($contentlevel) || $contentlevel eq ''){
	$contentlevel = -2;
}

#Set up the error count
#if($contentlevel == 2){
	#Content okay, so we'll reset the errorCounter
#	$errorCount{$siteName} = 0;
#}else{
#	++$errorCount{$siteName};
#}

### Insert website and status code into the cacti database.

if($mysqllog eq "yes"){		

		if ($contentlevel == 2) {

			my ($db,$table);
			my $output = new CGI;
			my $dbh = DBI->connect("dbi:mysql:$database:$dbserver", "$dbuser", "$dbpassword");	           
			my $table_data = $dbh->prepare("INSERT INTO REDmonitor (date,site,statuscode,responsetime,statuscount) VALUES(now(),'$site',$contentlevel,$subresptime,1)");
			$table_data->execute;
		}	
		
		elsif ($contentlevel < 2){	

	$sth = $dbh->prepare("	
				SELECT statuscount FROM REDmonitor WHERE ID = 
				(
				SELECT MAX(ID) as PenultimateResult FROM  REDmonitor WHERE site='$site'
				#AND ID != (
				#       SELECT MAX(ID) as LastResult FROM  REDmonitor WHERE site='$site'
				#    )
				)	
				");
				
	$sth->execute();
	my $getstatuscount = $sth->fetchrow_array();
	$sth->finish();	

			my $updatestatus=$getstatuscount+1;

			my ($db,$table);
			my $output = new CGI;
			my $dbh = DBI->connect("dbi:mysql:$database:$dbserver", "$dbuser", "$dbpassword");	           
			my $table_data = $dbh->prepare("INSERT INTO REDmonitor (date,site,statuscode,responsetime,statuscount) VALUES(now(),'$site',$contentlevel,$subresptime,$updatestatus)");
			$table_data->execute;

		}
}
###Get the last result for the current site.

	$sth = $dbh->prepare("	
				SELECT statuscode FROM REDmonitor WHERE ID = 
				(
				SELECT MAX(ID) as PenultimateResult FROM  REDmonitor WHERE site='$site'
				AND ID != (
				       SELECT MAX(ID) as LastResult FROM  REDmonitor WHERE site='$site'
				    )
				)	
				");
	$sth->execute();
	my $statuscode = $sth->fetchrow_array();
	$sth->finish();	

### Send the emails if certain conditions are meet.

if (($contentlevel == 1) && ($alert eq "yes")){

	my $subjectdown="$siteName is down or missing it's monitor tags";
	my $downmessage="Your website $siteName may have a problem. Status error code is $contentlevel (Incorrect content).\n
if your site is up please check the two monitoring tags are correct or are not missing. The tags are -\n
$header\n
$footer\n
Please don't reply to this email.\n
Response time was $subresptime.";

	$message=$downmessage;
	$subject=$subjectdown;

	&sendmail($fromaddr, $to, $smtp, $subject, $message );
}	
	elsif (($contentlevel < 1) && ($alert eq "yes")){
		
	my $subjectdown="$siteName is down.";
	my $downmessage="Your website $siteName is down. Status error code is $contentlevel.\n
REDmonitor was unable to contact your site.\n
Please don't reply to this email.\n
Response time was $subresptime.";

	$message=$downmessage;
	$subject=$subjectdown;

	&sendmail($fromaddr, $to, $smtp, $subject, $message );	
}	
	elsif (($contentlevel == 2) && ($statuscode < 2) && ($alert eq "yes")){

	$sth = $dbh->prepare("	
				SELECT statuscount FROM REDmonitor WHERE ID = 
				(
				SELECT MAX(ID) as PenultimateResult FROM  REDmonitor WHERE site='$site'
				AND ID != (
				       SELECT MAX(ID) as LastResult FROM  REDmonitor WHERE site='$site'
				    )
				)	
				");
				
	$sth->execute();
	my $getstatuscounttime = $sth->fetchrow_array();
	$sth->finish();	

  my $getstatuscounttime2=$getstatuscounttime*5;
		
	my $subjectup="$siteName is backup.";
	my $upmessage="Your website $siteName is backup and running correctly. Status code is $contentlevel.\n
REDmonitor estimates your site was down for $getstatuscounttime2 minutes.\n
Please don't reply to this email.\n
Response time was $subresptime.";

	$message=$upmessage;
	$subject=$subjectup;

	&sendmail($fromaddr, $to, $smtp, $subject, $message );	
}

print "ResponseTime:".$subresptime;
print " ";
print "ContentLevel:".$contentlevel;

1;