#!/usr/bin/perl -w

foreach my $file (split /\n/, `find "<REDACTED>" | grep '\\.pdf\$' | rl`) {
  system "/home/ajd/bin/read.pl $file";
}
