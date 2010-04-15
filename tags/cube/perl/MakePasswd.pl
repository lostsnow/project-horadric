#!/usr/bin/perl

my $characterset = 'abcdefghijkmnopqrstuvwxyz23456789ABCDEFGHIJKLMNPQRSTUVWXYZ';
#$characterset .= '~!@$%^()_{},./<>?-';
#$characterset .= "~!@$%^&*()_+|{},./<>?-=\";
#$characterset .= '~!@#$%^*()_|{},./<>?-=\';
$characterset .= '@#%^*()_=-~,.?;:|';
my $mininum = 8;
my $maxinum = 10;

sub MakePassword
{
    my ($composition, $lowlength, $highlength) = @_;
    return '' unless $composition;
    my @p = split //, $composition;
    my $arraylength = @p;
    $lowlength = 7 if $lowlength < 1;
    $highlength =7 if $highlength < 1;
    if ($lowlength > $highlength) {
        ($highlength, $lowlength) = ($lowlength, $highlength);
    }
    my $length = int(rand($highlength - $lowlength + 1));
    $length += $lowlength;
    my $password = '';
    for (1..$length) {
        my $i = int(rand($arraylength));
        $password .= $p[$i];
    }
    return $password;
}

my $password = MakePassword ($characterset, $mininum, $maxinum);
print $password;
