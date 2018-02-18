#!/usr/bin/perl -w

use Data::Dumper;
use DateTime;
use DateTime::Duration;
use DateTime::Format::Duration;

use Data::ICal;
#use Data::ICal::Entry::Event;

use Net::ICal::Attendee;
use Net::ICal::Time;
use Net::ICal::Calendar;
use Net::ICal::Event;

# my $cal = Net::ICal::Calendar->new();

$calendar = Data::ICal->new(filename => 'basic.ics.1');
my @events;
foreach my $entry (@{$calendar->{entries}}) {
  if (ref $entry eq "Data::ICal::Entry::TimeZone") {
    # skip this for now
  } elsif (ref $entry eq "Data::ICal::Entry::Event") {
    # print Dumper($entry);
    push @events, Net::ICal::Event->new
      (
       # organizer => Net::ICal::Attendee->new('aindilis'),
       # uid => "",
       # alarms => [],
       dtstart => Net::ICal::Time->new
       (
	ical => $entry->{properties}->{dtstart}->[0]->{value},
       ),
       dtend => Net::ICal::Time->new
       (
	ical => $entry->{properties}->{dtend}->[0]->{value},
       ),
       summary => $entry->{properties}->{summary}->[0]->{value},
      );
  }
}

my $cal = Net::ICal::Calendar->new
  (events => \@events);

print Dumper($cal);
