#!/usr/bin/perl
use Getopt::Std;
use Net::SMTP;
use MIME::Base64;

#h:host, f:mail from, u:user, p: passwd, s:subject, t:rcpt to
Getopt::Std::getopts('h:f:u:p:s:t:', \%options);

my $mailhost = $options{h};
my $mailfrom = $options{f};
my $mailuser = $options{u};
my $mailpasswd = $options{p};
my $subject = $options{s};
my $mailto = $options{t};

while (defined($line = <STDIN>)) {
    $content .= $line;
}

#print "$mailhost:$mailfrom:$mailuser:$mailpasswd:$subject:$mailto:$content\n";
#exit(0);

open(LOG,">>/var/log/notify.log");

my $smtp = Net::SMTP->new($mailhost, Debug => 1);

# after $stmp = Net::SMTP->new
#$smtp->command('AUTH PLAIN')->response();
#my $userpass = encode_base64("\000$mailuser\000$mailpasswd");
#$userpass =~ s/\n//g;
#$smtp->command($userpass)->response();

# anth login, type your user name and password here
$smtp->auth($mailuser, $mailpasswd);

# Send the From and Recipient for the mail servers that require it
$smtp->mail($mailfrom); 
$smtp->to($mailto); 

# Start the mail
$smtp->data(); 

# Send the header
$smtp->datasend("To: $mailto\n");
$smtp->datasend("From: $mailfrom\n");
$smtp->datasend("Subject: $subject\n");
$smtp->datasend("Content-Type: text/plain; charset=utf-8\n");
$smtp->datasend("\n");

# Send the message
$smtp->datasend("$content\n\n"); 
$smtp->dataend();

$smtp->quit;

my $date_command = "/bin/date";
my $date = `$date_command`; chop($date);
print LOG "$date: Sent Msg $content to $to\n";
close(LOG);
exit(0);