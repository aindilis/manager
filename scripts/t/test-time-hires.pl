#!/usr/bin/perl -w

use Data::Dumper;
use Time::HiRes qw(gettimeofday tv_interval);

my $t0 = [gettimeofday];
sleep 1;
my $t1 = [gettimeofday];
my $elapsed = tv_interval ( $t0, $t1);
print Dumper($elapsed);
