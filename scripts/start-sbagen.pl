#!/usr/bin/perl -w

use Data::Dumper;

my $dir = "/var/lib/myfrdcsa/codebases/internal/manager/data/sbagen";
my @files = split /\n/,`ls $dir/prog-[0-9]*`;
my $file = $files[int(rand(scalar @files))];

my $c = "sbagen -Q -S \"$file\"";
print "$c\n";
system "$c";

