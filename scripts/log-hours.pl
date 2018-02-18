#!/usr/bin/perl -w

use Manager::Dialog qw(QueryUser);

use IO::Socket::SSL;
use LWP::UserAgent;
use WWW::Mechanize;

my $url = "<REDACTED>";
# go ahead and log your hours on the website, timesheet

my $mech = WWW::Mechanize->new(autocheck => 1);
$mech->credentials($url, "https", '<REDACTED>', '<REDACTED>');
$mech->get("https://$url");
print $mech->content(format => "text");

exit(0);


if (0) {
  my $client = IO::Socket::SSL->new("<REDACTED>:https");
  if ($client) {
    print $client "GET / HTTP/1.0\r\n\r\n";
    print <$client>;
    close $client;
  } else {
    warn "I encountered a problem: ",
      IO::Socket::SSL::errstr();
  }
}

$ENV{HTTPS_PROXY} = 'http://<REDACTED>:443';
$ENV{HTTPS_DEBUG} = 1;
$ENV{HTTPS_VERSION} = '3';
$ENV{HTTPS_PROXY_USERNAME} = 'andrewd';
$ENV{HTTPS_PROXY_PASSWORD} = 'D0ugh3ty$:';

my $ua = new LWP::UserAgent;
my $req = new HTTP::Request('GET', 'https://<REDACTED>');
my $res = $ua->request($req);
print $res->content."\n";

