package Manager::AM::Motion;

# $resolution = "-s640x480";
# $resolution = "";

sub StartMotionDetection {
  $recon = "-t/home/ajd/recon";
  my $command = "motion $recon -g 1 -E \"play /usr/lib/openoffice/share/gallery/sounds/laser.wav\" >/dev/null 2>/dev/null";
  print $command."\n";
  system $command;
}

1;
