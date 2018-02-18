#!/usr/bin/perl

use WWW::Mechanize;

use Crypt::SSLeay;

# What site are we connecting to?
my $url = "https://<REDACTED>";

# Username
my $username = '<REDACTED>';

# Password
my $password = '<REDACTED>';

# Create a new instance of WWW::Mechanize
my $mechanize = WWW::Mechanize->new(autocheck => 1);

# Supply the necessary credentials
$mechanize->credentials($url, "<REDACTED>", $username, $password);

# Retrieve the desired page
$mechanize->get("https://<REDACTED>");

