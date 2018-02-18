#!/usr/bin/perl -w

my $readlist = $ARGV[0] || "lists/temp.rl";

StartAll();

sub StartAll {
  my $live = 1;

  # kill existing processes that would interfere
  if ($live) {
    StopAll();
  }

  if ($live) {
    system "/home/ajd/bin/sanctus &";
  }

  # start up motion detection
  if ($live) {
    print "Starting motion detection\n";
    system "/home/ajd/bin/arm &";
  }

  if ($live) {
    print "Starting alarm\n";
    system "/home/ajd/bin/next-alarm.pl &";
  }

  # now choose from among the available read lists and run clair
  if ($live) {
    print "Starting Clairvoyance\n";
    chdir "/home/ajd/myfrdcsa/codebases/internal/clairvoyance";
    system "./clair $readlist";
  }

  if ($live) {
    print "Securing system\n";
    # system "/home/ajd/bin/secure";
  }

  StopAll();
}

sub StopAll {
  print "Stopping previously running programs\n";
  # system "killall -9 sleep-learning";
  system "killall -9 arm";
  system "killall -9 motion";
  system "killall -9 clair";
  system "killall -9 alarm";
}
