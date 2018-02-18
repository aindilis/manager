#!/usr/bin/perl -w

use Manager::Dialog qw(ApproveCommands);

sub RecordSound {
  my $recdir = "/var/lib/myfrdcsa/codebases/internal/manager/data/sound-recordings";
  @logs = split(/\s+/,`ls $recdir/rec*.spx`);
  $max = 0;
  foreach $log (@logs) {
    $log =~ /.*?([0-9]+)\.spx$/;
    if ($1 > $max) {
      $max = $1;
    }
  }

  my $commands =
    [
     "sox -t ossdsp /dev/dsp -t wav - | ".
     "speexenc --quality 1 --vbr --dtx - $recdir/rec" . ($max + 1) .".spx",
    ];

  ApproveCommands
    (Commands => $commands,
     Method => "parallel");
}

RecordSound;
