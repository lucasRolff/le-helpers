#!/usr/bin/perl -w

use strict;
use Getopt::Long;

if ( @ARGV > 0 ) {
    GetOptions(
        'domain|d=s' => \ my $domain,
        'no-www|n'   => \ my $nowww,
        'help|h'     => \ my $help,
    ) or die "Usage: $0 --domain example.com [--no-www]\n";

    if ($help || !$domain )
    {
        do_help();
    }

    my $www=" www.$domain";
    if($nowww) {
        $www="";
    }

    my $domainlist="$domain$www";

    print "Generating certificate for following domain(s): $domainlist\n";

    chomp(my $webroot=`cat /etc/userdatadomains | grep ^$domain | awk -F== '{print \$5}'`);

    print "Found webroot: $webroot\n";
    print "Generating SSL from Let's Encrypt\n";
    my $le_result=`/bin/le issue $webroot $domainlist\n`;

    print "$le_result\n";

    print "Installing SSL for domain $domain\n";
    my $install_result=`cd /root/scripts; ./installssl.pl $domain`;
    print "$install_result\n";
    print "SSL Installed!\n";
}
else
{
    do_help();
}
sub do_help {
  die "To use this tool you have following options:
    (required)-d|--domain: The domain you want to generate a SSL certificate for
    (optional)-n|--no-www: Do not include www. in the SSL certificate\n";
}
