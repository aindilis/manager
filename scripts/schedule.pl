#!/usr/bin/perl -w

@sched = (
	  "SHOPS",
	  "Stat",
	  "SHOPS",
	  "FRDCSA",
	  "SHOPS",
	  "Stat",
	  "Stat",
	  "FRDCSA",
	  "SHOPS",
	  "Stat",
	  "SHOPS"
	 );

my $sec = `date +%s`;
my $offset = 1091621088;
my $index = (($sec - $offset) / (24 * 60 * 60)) % (scalar @sched);

print "Work on ".$sched[$index]."\n";
