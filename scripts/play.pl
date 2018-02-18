#!/usr/bin/perl -w

use Manager::Dialog qw(ApproveCommands Choose SubsetSelect);

sub PlaySound {
  my $recdir = "/var/lib/myfrdcsa/codebases/internal/manager/data/sound-recordings";
  my @files = split(/\s+/,`ls $recdir/rec*.spx`);
  my $commands = [];
  foreach my $file (SubsetSelect(Set => \@files)) {
    push @$commands, "speexdec \"$file\"";
  }
  ApproveCommands
    (Commands => $commands,
     Method => "parallel");
}

PlaySound;
