#!/usr/bin/perl -w

foreach my $file (split /\n/, `find /home/ajd/casos.isri.cmu.edu/home/ajd/central | grep '\\.pdf\$' | rl`) {
  system "/home/ajd/bin/read.pl $file";
}
