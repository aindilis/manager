#!/usr/bin/perl -w

use Data::Dumper;
use Net::ICal::Calendar;
use Net::ICal::Component;

my $to = "/tmp/huh";
mkdir ($to,0775);
my $calendar = Net::ICal::Calendar->new();
print Dumper($calendar);

my $incoming = $calendar->get_incoming();

my $text = `cat basic.ics.1`;
my $comp = Net::ICal::Component->new(\$text);
$incoming->add($comp);
print Dumper($incoming);
