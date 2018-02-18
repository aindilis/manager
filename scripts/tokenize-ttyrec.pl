#!/usr/bin/perl -w

# maybe do somekind of efficient maximal subsequence dictionary lookup
# test?

my $dict = {};
my $ttyrecfile = $ARGV[0];
my $command;
if ($ttyrecfile =~ /\.gz$/i) {
  $command = "zcat";
} else {
  $command = "cat";
}
my $c = `$command $ttyrecfile`;
foreach my $w (split /[^a-zA-Z]+/,$c) {
  $dict->{$w} = 1;
}
print join("\n", sort keys %$dict);
