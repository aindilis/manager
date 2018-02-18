#!/usr/bin/perl -w

my $imagedir = "/var/lib/myfrdcsa/projects/POSI/people/images";

system "manager --contexts -j $imagedir/contexts.jpg";
# system "manager --plotdaily -j $imagedir/daily.jpg";
# system "manager --plotmeasures -j $imagedir/measures.jpg";

