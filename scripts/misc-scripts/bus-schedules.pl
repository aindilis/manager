#!/usr/bin/perl -w

use Util;

my $busscheddir = "/home/ajd/myfrdcsa/codebases/busroute/data/pittsburgh-schedules";
my @buses = map {s/.*\///; s/\.pdf//; $_} split /\n/, `ls $busscheddir/*.pdf`;
Message("Which bus do you want?");
system "acroread $busscheddir/" . $buses[Choose(@buses)] . ".pdf";
