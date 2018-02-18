package Manager::AM::Alarm;

use Data::Dumper;
use Term::ReadKey;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       => [ qw / Targets Target / ];

sub init {
  my ($self, %args) = @_;
  $self->Targets([qw(pager localspeaker)]);
  $self->Target($args{Target} || "pager");
}

sub SynchronizeClock {
  my ($self,%args) = @_;
  print "Synchronizing clock";
  system "sudo /usr/sbin/ntpdate us.pool.ntp.org";
}

sub SetAlarm {
  my ($self,%args) = @_;
  if (! defined $args{NoRepeat}) {
    $self->SynchronizeClock;

    my $ok = 0;
    if ($self->Target eq "localspeaker") {
      if ($self->SoundCheck) {
	$ok = 1;
      } else {
	die "sound not confirmed";
      }
    } else {
      $ok = 1;
    }

    $self->CleanCharacterQueue;
    my $response;
    if (defined $args{Delay} and $args{Delay} > 0) {
      $response = $self->Alarm(Delay => $args{Delay});
    } elsif (defined $args{Time}) {
      $response = $self->TimeAlarm(Time => $args{Time});
    } else {
      $response = $self->NextAlarm();
    }
    if ($self->Target eq "localspeaker") {
      while ($response ne "q") {
	if ($response eq "n") {
	  $response = $self->NextAlarm();
	} else {
	  $response = $self->Alarm
	    (Delay => 300);
	}
      }
    }
  }
}

sub CleanCharacterQueue {
  my ($self,%args) = @_;
  ReadMode('cbreak');
  while (defined ($char = ReadKey(-1))) {
    # clean the character queue
  }
  ReadMode('normal');
}

sub SoundCheck {
  my ($self,%args) = @_;
  $self->SetVolume(Volume => "medium");
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

sub SetVolume {
  my ($self,%args) = @_;
  my $volume = $args{Volume};
  my $homedir = "/home/andrewd";
  system "$homedir/bin/volume $volume > /dev/null";
}

sub Alarm {
  my ($self,%args) = @_;
  my ($delay) = $args{Delay};
  print "Setting alarm for $delay seconds\n";
  sleep $delay;
  return $self->SoundTheAlarm;
}

sub SoundTheAlarm {
  my ($self,%args) = @_;
  if ($self->Target eq "localspeaker") {
    $self->SetVolume(Volume => "loud");
    my $char;
    ReadMode('cbreak');
    while (! defined ($char = ReadKey(-1))) {
      print "Wakeup\n";
      system 'date "+%k %M %A" > /tmp/date';
      system "festival --tts /tmp/date";
      sleep 5;
    }
    ReadMode('normal');
    $self->SetVolume(Volume => "medium");
    return $char;
  } elsif ($self->Target eq "pager") {
    print "Sending myself a page\n";
    my $receiver = "page-andrewd\@onshore.com";
    my $messagefile = "/tmp/messagefile";
    my $OUT;
    open(OUT, ">$messagefile");
    print OUT "Manager::AM::Alarm set to page you now.";
    close(OUT);
    system "/usr/sbin/sendmail -i $receiver < $messagefile";
  }
}

sub TimeAlarm {
  my ($self,%args) = @_;
  my $alarm = $args{Time};

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
  return $self->Alarm(Delay => $seconds);
}

sub NextAlarm {
  my ($self,%args) = @_;
  # start the alarm
  # ensure time is correct

  # determine time to the next sleeping node
  my ($curtime) = split /[-\n]/,`date "+%H%M%S"`;
  print "Current time is  $curtime\n";

  my @wakeuptimes = qw ( 060000 070000 090000 100000 120000 140000 224500 234500 235959);
  do {
    $alarm = shift @wakeuptimes;
  } while ($alarm < $curtime);
  print "Setting alarm to $alarm\n";
  # now determine how many seconds this is

  my ($h1,$m1,$s1) = ($alarm =~ /([0-9]{2})([0-9]{2})([0-9]{2})/);
  my ($h2,$m2,$s2) = ($curtime =~ /([0-9]{2})([0-9]{2})([0-9]{2})/);
  $seconds = (60 * (60 * ($h1 - $h2) + $m1 - $m2)) + $s1 - $s2;

  print "Wakeup in $seconds seconds\n";
  return $self->Alarm(Delay => $seconds);
}

1;
