#!/usr/bin/perl
use CGI;
use CGI::Cookie;
use C4::Auth_with_openid;
use C4::Koha;
use Net::Google::FederatedLogin;

my $q = CGI->new();
my $bounce = $q->param('bounce'); 
my $return_to = "http://catalog.wmu.se/cgi-bin/koha/opac-openidreturn.pl";

if (!$bounce) {
	$bounce = "/cgi-bin/koha/opac-user.pl";
} else { 
	$return_to = $return_to . "?bounce=" . $bounce;
}

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
   #print "ok";   
   # we've authenticated and gotten attributes --
    my $ext = $fl->get_extension('http://openid.net/srv/ax/1.0');
    $email =  $ext->get_parameter('value.email'); 
    $sessionID = auth_with_openid($email);
    
    if ( defined $sessionID ) {
      my $cookie = $q->cookie(-name => 'CGISESSID', -value => $sessionID);
	      print  $q->redirect(-uri =>  $bounce, -cookie => $cookie);
    } else {
print "There has been an error. Please contact the library staff to login with you Google ID.";
      print "<a href='http://catalog.wmu.se'>Return to WMU Catalog</a>";
  
  }
}

