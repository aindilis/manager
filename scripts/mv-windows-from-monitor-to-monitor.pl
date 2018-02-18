#!/usr/bin/perl -w

use PerlLib::SwissArmyKnife;

my $screensizes = [[[1920,1080],[1920,1080]]];

my $windows = `wmctrl -l -G`;

my @windows;
foreach my $line (split /\n/, $windows) {
  # 0x0180011b  1 89   98   1840 1027 ai emacs@ai.frdcsa.org
  if ($line =~ /^(\w+x\w+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(.+?)\s+(.+?)$/) {
    push @windows,
      {
       id => $1,
       xOffset => $2,
       yOffset => $3,
       xSize => $4,
       ySize => $5,
       host => $6,
       windowName => $7,
      };
  }
}

foreach my $window (@windows) {
  print Dumper(getMonitorOfWindow(Window => $window));
}

sub getMonitorOfWindow {
  my (%args) = @_;
  my $initialxoffset = 0;
  my $initialyoffset = 0;
  my $row = 0;
  foreach my $rowofmonitors (@$screensizes) {
    ++$row;
    my $column = 0;
    foreach my $screensize (@$rowofmonitors) {
      ++$column;
      if ($args{xOffset} >= $initialxoffset and $args{xOffset} <= ($initialxoffset + $screensize->[0])) {
	$args{Window}{monitor} = [$column,0];
      }
      $initialxoffset += $screensize->[0];
    }
  }
  return $args{Window};
}
