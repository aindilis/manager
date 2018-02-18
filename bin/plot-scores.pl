#!/usr/bin/perl -w

my $imagedir = "/var/www/frdcsa/people/andrewd/metrics";
system "manager --contexts -j $imagedir/contexts.jpg >> /tmp/text2 2>> /tmp/text2";
system "manager --plotdaily -j $imagedir/daily.jpg >> /tmp/text2 2>> /tmp/text2";
system "manager --plotmeasures -j $imagedir/measures.jpg >> /tmp/text2 2>> /tmp/text2";
