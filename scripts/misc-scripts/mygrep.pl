#!/usr/bin/perl -w

my $dir = shift;
my $regex = shift;
foreach my $file (split /\n/,`find $dir`) {
  $contents = `cat \"$file\"`;
  if ($contents =~ /$regex/) {
    print "1: $file\n"
  } else {
    print "0: $file\n"
  }
}
