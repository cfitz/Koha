#!/usr/bin/perl
use CGI;
use URI::Escape;

my $q = CGI->new();
my $proxy = $q->param('proxy');
my $safe_url = $q->param('url');
my $url = uri_unescape($safe_url);
my $redirect = "";

if ($proxy eq "Yes") {
 $redirect = "http://proxy.wmu.se/login?url=" . $url;
} else {
 $redirect = $url; 
}

print $q->redirect($redirect);
