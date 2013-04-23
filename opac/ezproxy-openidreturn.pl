#!/usr/bin/perl
use CGI;
use Net::Google::FederatedLogin;
use MD5;

my $EZproxyStartingPointURL = "";

sub EZproxyURLInit
{
  my ($EZproxyServerURL, $secret, $user, $groups) = @_;
  my ($packet, $EZproxyTicket);

  if ($secret eq "") {
    die "EZproxyURLInit secret missing";
  }

  $packet = '$u' . time();
  if ($groups ne "") {
    $packet .= '$g' . $groups;
  }
  $packet .= '$e';
  $EZproxyTicket = CGI::escape(MD5->hexhash($secret . $user . $packet) . 
                               $packet);
  $EZproxyStartingPointURL = $EZproxyServerURL . "/login?user=" . 
    CGI::escape($user) . "&ticket=" . $EZproxyTicket;
}

sub EZproxyURL
{
  my ($url) = @_;

  if ($EZproxyStartingPointURL eq "") {
    die "EZproxyURLInit must be called before EZproxyURL";
  }

  return $EZproxyStartingPointURL . "&qurl=" . CGI::escape($url);
}




my $q = CGI->new();
my $bounce = $q->param('bounce'); 
my $return_to = "http://catalog.wmu.se/cgi-bin/koha/ezproxy-openidreturn.pl";
$return_to = $return_to . "?bounce=" . $bounce;




my $fl = Net::Google::FederatedLogin->new(  
    cgi => $q,
    return_to => $return_to
    );

eval { $fl->verify_auth(); };
if ($@) {
    print $q->header();
    print 'Error: ' . $@;
}
else {
    # we've authenticated and gotten attributes --
    my $ext = $fl->get_extension('http://openid.net/srv/ax/1.0');
    $email =  $ext->get_parameter('value.email');
 		$key = `echo $EZ_PROXY_KEY`; # define a system env variable with your key.
    EZproxyURLInit("http://proxy.wmu.se", $key, $email );
    $url =  EZproxyURL($bounce);
    print $q->redirect(-uri =>  $url);    
}
