#!/usr/bin/perl -w

use Data::Dumper;
use Time::HiRes qw(usleep);

my $lastvalue;
while (1) {
  # usleep 500000;
  sleep 1;
  my $res = `hcitool rssi 00:13:17:71:CE:0F`;
  if ($res =~ /^RSSI return value: (.+)\s*$/) {
    my $value = $1;
    if ($value != $lastvalue) {
      print $value."\n";
    }
    $lastvalue = $value;
    if ($value < -7) {
      print "LOCK!\n";
      system "gnome-screensaver-command --lock";
    }
  } else {
    print "ERROR\n";
  }
}
