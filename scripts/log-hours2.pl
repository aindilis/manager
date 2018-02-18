#!/usr/bin/perl

use strict;

use warnings;

use WWW::Mechanize;

use Crypt::SSLeay;

 #it is installed

my $mech = WWW::Mechanize->new();

$mech->agent_alias( 'Windows IE 6' );

$mech->get( "https://<REDACTED>/" );

print $mech->content;
