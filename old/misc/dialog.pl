#!/usr/bin/perl -w

use Data::Dumper;

my $FILE;
open(FILE,"/usr/bin/sphinx2-demo |") or
  die "can't open sphinx2-demo\n";
my $state = 0;
my $pass;
my $OUT;

my %commands = (
		"three" => \&VolumeMute,
		"six" => \&VolumeMedium,
		# "one|what" => \&ClairStart,
		# "five" => \&ClairStop,
		"three" => \&ClairForward,
		"do|two|to" => \&MusicStart,
		"four|forward" => \&MusicForward,
		"backward" => \&MusicBackward,
		"one|what" => \&SleepStart,
		"five" => \&SleepStop,
		"ninety" => sub { system "killall xmms" },
		# "stop" => ,
		# "physical security" => ,
		# "list activities" => ,
	       );

print Dumper([keys %commands]);

print "[initializing]\n";
while ($line = <FILE>) {
  chomp $line;
  if ($line =~ /\[initializing\]/) {
    $state = 1;
    print "[initialized]\n";
  } elsif ($state == 1) {
    print "$line\n";
    $pass = 0;
    foreach my $key (keys %commands) {
      if (eval {$line =~ /$key/i}) {
	print "$key\n";
	&{$commands{$key}};
      }
    }
  }
}

sub VolumeMute {
  system "echo aumix -f /home/ajd/myfrdcsa/codebases/meeting/aumix/aumix.mute -L q";
  system "aumix -f /home/ajd/myfrdcsa/codebases/meeting/aumix/aumix.mute -L q";
}

sub VolumeMedium {
  system "echo aumix -f /home/ajd/myfrdcsa/codebases/meeting/aumix/aumix.medium -L q";
  system "aumix -f /home/ajd/myfrdcsa/codebases/meeting/aumix/aumix.medium -L q";
}

sub ClairStart {
  print "Starting reading services\n";
  # system "/home/ajd/bin/services -y reading &";
  chdir "/home/ajd/myfrdcsa/codebases/clairvoyance/";
  system "./clair army.rl &";
}

sub ClairStop {
  print "Stop reading\n";
  system "ps aux --cols=200 | grep -i read-aloud | awk '{print \$2}' | xargs kill -9";
  system "ps aux --cols=200 | grep xpdf | awk '{print \$2}' | xargs kill -9";
}

sub SleepStart {
  print "Starting reading services\n";
  # open(OUT, "| /home/ajd/bin/sleep-learning");
  system "/home/ajd/bin/sleep-learning &";
}

sub SleepStop {
  print "Stop reading\n";
  print OUT "q";
  print OUT "q";
  print OUT "q";
}

sub ClairForward {
  print "Next pdf\n";
  system "ps aux --cols=200 | grep xpdf | awk '{print \$2}' | xargs kill -9";
}

sub MusicStart {
  print "Starting music services\n";
  system "/home/ajd/bin/services -y music &";
  system "xmms -p &";
}

sub MusicForward {
  system "xmms -f";
}

sub MusicBackward {
  system "xmms -r";
}


# more items

# time - what is the time
# bus ?busname - what is the schedule for this bus?
# stop/start motion detection/face rec/etc
# volume ?level
# record - record audio from the user (at least until dictation works, to record important thoughts)

# set dialog to run as an /etc/init.d/dialog start service.
