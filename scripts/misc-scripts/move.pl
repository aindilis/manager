#!/usr/bin/perl -w

my $d1 = shift;
my $d2 = shift;
my $regex = shift;
foreach my $file (split /\n/,`find $d1`) {
  if (-f $file) {
    if ($file =~ /$regex/) {
      system "mv \"$file\" \"$d2\"";
    }
  }
}
