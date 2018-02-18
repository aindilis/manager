#!/usr/bin/perl -w

my $inc = shift;
my $pre = shift;
my $post = shift;
while (@ARGV) {
  @group = splice(@ARGV,0,$inc);
  my $command = "$pre ".join(" ",map "\"$_\"", @group)." $post";
  system "$command\n";
}
