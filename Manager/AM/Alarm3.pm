package Manager::AM::Alarm;

# depending on the type of alarm, page me

require Exporter;
@ISA = qw(Exporter);
@EXPORT = qw ( SetAlarm );

use Term::ReadKey;

sub SetAlarm {
  my (%args) = (@_);
  if (! defined $args{NoRepeat}) {
    print "Fixing time";
    system "sudo ~/bin/fixtime";

    my $response;
    if (TestSound()) {
      ReadMode('cbreak');
      while (defined ($char = ReadKey(-1))) {
	# clean the character queue
      }
      ReadMode('normal');
      if (defined $args{Delay} and $args{Delay} > 0) {
	$response = Alarm($args{Delay});
      } elsif (defined $args{Time}) {
	$response = TimeAlarm($args{Time});
      } else {
	$response = NextAlarm();
      }
      while ($response ne "q") {
	if ($response eq "n") {
	  $response = NextAlarm();
	} else {
	  $response = Alarm(300);
	}
      }
    } else {
      die "sound not confirmed";
    }
  }
}

sub TestSound {
  Volume("medium");
  my $char;
  ReadMode('cbreak');
  my $count = 0;
  while ($count++ < 10 and ! defined ($char = ReadKey(-1))) {
    print "Can you hear this? /[yn]/i\n";
    system "festival --tts /var/lib/myfrdcsa/codebases/internal/manager/data/wakeup.txt";
  }
  ReadMode('normal');
  return $char =~ /y/i;
}

sub Volume {
  my $volume = shift;
  my $homedir = "/home/jasayne";
  system "$homedir/bin/volume $volume > /dev/null";
}

sub Alarm {
  my ($delay) = (shift);
  print "Setting alarm for $delay seconds\n";
  Volume("medium");
  sleep $delay;
  Volume("loud");
  my $char;
  ReadMode('cbreak');
  while (! defined ($char = ReadKey(-1))) {
    print "Wakeup\n";
    system 'date "+%k %M %A" > /tmp/date';
    system "festival --tts /tmp/date";
    sleep 5;
  }
  ReadMode('normal');
  Volume("medium");
  return $char;
}

sub TimeAlarm {
  my $alarm = shift;

  # determine time to the next sleeping node
  my ($curtime) = split /[-\n]/,`date "+%H%M%S"`;
  print "Current time is  $curtime\n";
  print "Setting alarm to $alarm\n";

  while ($alarm < $curtime) {
    $alarm += 240000;
  }

  # now determine how many seconds this is
  my ($h1,$m1,$s1) = ($alarm =~ /([0-9]{2})([0-9]{2})([0-9]{2})/);
  my ($h2,$m2,$s2) = ($curtime =~ /([0-9]{2})([0-9]{2})([0-9]{2})/);
  $seconds = (60 * (60 * ($h1 - $h2) + $m1 - $m2)) + $s1 - $s2;

  print "Wakeup in $seconds seconds\n";
  return Alarm($seconds);
}

sub NextAlarm {
  # start the alarm
  # ensure time is correct

  # determine time to the next sleeping node
  my ($curtime) = split /[-\n]/,`date "+%H%M%S"`;
  print "Current time is  $curtime\n";

  my @wakeuptimes = qw (060000 070000 090000 100000 120000 140000 224500 234500 235959);
  do {
    $alarm = shift @wakeuptimes;
  } while ($alarm < $curtime);
  print "Setting alarm to $alarm\n";
  # now determine how many seconds this is

  my ($h1,$m1,$s1) = ($alarm =~ /([0-9]{2})([0-9]{2})([0-9]{2})/);
  my ($h2,$m2,$s2) = ($curtime =~ /([0-9]{2})([0-9]{2})([0-9]{2})/);
  $seconds = (60 * (60 * ($h1 - $h2) + $m1 - $m2)) + $s1 - $s2;

  print "Wakeup in $seconds seconds\n";
  return Alarm($seconds);
}

1;
