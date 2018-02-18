#!/usr/bin/perl -w

# program to sort files in home  directory, isnce our other one is not
# here.

my $homedir = "/home/ajd";
foreach my $file (split /\n/, `ls $homedir`) {
  $ext = $file;
  $ext =~ s/.*\.//;
}
