#!/usr/bin/perl -w

use Data::Dumper;
use Net::Google::Calendar;
use DateTime;
use DateTime::Duration;
use DateTime::Format::Duration;

use Data::ICal;
# Data::ICal::Entry::Event


if (0) {
  foreach my $url (split /\n/, `cat calendars`) {
    my $cal = Net::Google::Calendar->new( url => $url );
    for ($cal->get_events()) {
      print Dumper($_->when);
    }
  }
}

$calendar = Data::ICal->new(filename => 'basic.ics.1');
# print Dumper($calendar);
my $tzoffsetfrom;
my $tzoffsetto;
my ($durationfrom, $durationto);
foreach my $entry (@{$calendar->{entries}}) {
  # print Dumper($entry);
  if (ref $entry eq "Data::ICal::Entry::TimeZone") {
    $tzoffsetfrom = $entry->{entries}->[1]->{properties}->{tzoffsetfrom}->[0]->{value};
    $tzoffsetto = $entry->{entries}->[1]->{properties}->{tzoffsetto}->[0]->{value};
    if ($tzoffsetfrom =~ /^(-?\d{2})(\d{2})$/) {
      $durationfrom = DateTime::Duration->new
	(
	 hours => $1,
	 minutes => $2,
	);
    }
    if ($tzoffsetto =~ /^(-?\d{2})(\d{2})$/) {
      $durationto = DateTime::Duration->new
	(
	 hours => $1,
	 minutes => $2,
	);
    }
  } elsif (ref $entry eq "Data::ICal::Entry::Event") {
    my $dtstart = $entry->{properties}->{dtstart}->[0]->{value};
    my $dtend = $entry->{properties}->{dtend}->[0]->{value};
    # 20081125T010000
    if ($dtstart =~ /^(\d{4})(\d{2})(\d{2})T(\d{2})(\d{2})(\d{2})Z$/) {
      # calculate the correct date by adding the timezone
      $dtstartdatetime = DateTime->new
	(
	 year => $1,
	 month => $2,
	 day => $3,
	 hour => $4,
	 minute => $5,
	 second => $6,
	) + $durationto;

    } elsif ($dtstart =~ /^(\d{4})(\d{2})(\d{2})T(\d{2})(\d{2})(\d{2})/) {
      $dtstartdatetime = DateTime->new
	(
	 year => $1,
	 month => $2,
	 day => $3,
	 hour => $4,
	 minute => $5,
	 second => $6,
	);
    }
    if ($dtend =~ /^(\d{4})(\d{2})(\d{2})T(\d{2})(\d{2})(\d{2})Z$/) {
      # calculate the correct date by adding the timezone
      $dtenddatetime = DateTime->new
	(
	 year => $1,
	 month => $2,
	 day => $3,
	 hour => $4,
	 minute => $5,
	 second => $6,
	) + $durationto;

    } elsif ($dtend =~ /^(\d{4})(\d{2})(\d{2})T(\d{2})(\d{2})(\d{2})/) {
      $dtenddatetime = DateTime->new
	(
	 year => $1,
	 month => $2,
	 day => $3,
	 hour => $4,
	 minute => $5,
	 second => $6,
	);
    }
    my $summary = $entry->{properties}->{summary}->[0]->{value};
    # print Dumper($entry);
    # print join("\t",$tzoffsetfrom,$tzoffsetto,$dtstart,$dtend,$summary)."\n";
    print join("\t",$dtstartdatetime->ymd."T".$dtstartdatetime->hms,
	       $dtenddatetime->ymd."T".$dtenddatetime->hms,$summary)."\n";
    print Dumper($entry);
  }
}
