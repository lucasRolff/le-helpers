#!/usr/local/cpanel/3rdparty/bin/perl

use strict;
use LWP::UserAgent;
use LWP::Protocol::https;
use MIME::Base64;
use IO::Socket::SSL;
use URI::Escape;

my $user = "root";

system '/usr/local/cpanel/bin/mkaccesshash' if !-e '/root/.accesshash';

my $IN;

open $IN, "<", "/root/.accesshash" or die "Cannot open accesshash";
my @lines = <$IN>;
close $IN;

my $accesshash;
foreach my $line (@lines)
{
    chomp $line;
    $accesshash .= $line;
}

my $auth = "Basic " . MIME::Base64::encode( $user . ":" . $accesshash );

my $ua = LWP::UserAgent->new(
    ssl_opts   => { verify_hostname => 0, SSL_verify_mode => 'SSL_VERIFY_NONE', SSL_use_cert => 0 },
);

my $dom = $ARGV[0];

my $certfile = "/root/.le/$dom/$dom.cer";
my $keyfile = "/root/.le/$dom/$dom.key";
my $cafile =  "/root/.le/$dom/ca.cer";

my $certdata;
my $keydata;
my $cadata;

open(my $certfh, '<', $certfile) or die "cannot open file $certfile";
    {
        local $/;
        $certdata = <$certfh>;
    }
    close($certfh);

open(my $keyfh, '<', $keyfile) or die "cannot open file $keyfile";
    {
        local $/;
        $keydata = <$keyfh>;
    }
    close($keyfh);

open(my $cafh, '<', $cafile) or die "cannot open file $cafile";
    {
        local $/;
        $cadata = <$cafh>;
    }
    close($cafh);

my $cert = uri_escape($certdata);
my $key = uri_escape($keydata);
my $ca = uri_escape($cadata);

my $request = HTTP::Request->new( POST => "https://127.0.0.1:2087/json-api/installssl?api.version=1&domain=$dom&crt=$cert&key=$key&cab=$ca" );
$request->header( Authorization => $auth );
my $response = $ua->request($request);
print $response->content;
