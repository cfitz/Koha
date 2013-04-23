#!/usr/bin/perl
use CGI;
use Net::Google::FederatedLogin;
 use warnings;
my $q = CGI->new();

my $domain = $q->param('domain');
if (!$domain) {
	$domain = "http://www.wmu.se";
}

my $bounce = 'http://catalog.wmu.se/cgi-bin/koha/opac-openidreturn.pl'; 
if ( $ENV{'HTTP_REFERER'} =~ m/wmu.se/ ) {
	$ref_url = $ENV{'HTTP_REFERER'};
	$ref_url =~ s/logout\.x\=1//g;
	$bounce = $bounce . "?bounce=" . $ref_url;
	}

my $fl = Net::Google::FederatedLogin->new(
    claimed_id => 
        'https://www.google.com/accounts/o8/site-xrds?hd=' . $domain,
    realm => "http://catalog.wmu.se/", 
    return_to => $bounce,
    extensions => [
        {
            ns          => 'ax',
            uri         => 'http://openid.net/srv/ax/1.0',
            attributes  => {
                mode        => 'fetch_request',
                required    => 'email',
                type        => {
                    email => 'http://axschema.org/contact/email'
                }
            }
        }
    ] );
print $q->redirect($fl->get_auth_url());
