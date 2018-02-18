package Manager::State::Sleep;

# program to estimate sleep periods, among other things, from data

# very easy thing to do, simply create a bounding box fit over time to
# determine  absenses.  First,  however, computer  all  large absenses
# (maybe in a fuzzy way)

use Manager::Dialog qw(Message);
use PerlLib::MySQL;
use System::GnuPlot;

use Data::Dumper;
use DateTime;

use File::Stat;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / MyMySQL LatestTime EarliestTime LastHour Times Bins Params /

  ];

sub init {
  my ($self, %args) = @_;
  $self->MyMySQL
    (PerlLib::MySQL->new
     (DBName => "unilang"));
}

sub Execute {
  my ($self, %args) = @_;
  $self->RetrieveTimes();
  # $self->SaveTimes();
  # $self->LoadTimes();
  $self->GenerateBins();
  $self->FitSleep();
  if (1 or $args{Display}) {
    $self->DisplayParams;
    $self->Plot();
  }
}

sub RetrieveTimes {
  my ($self, %args) = @_;
  my $s = "select UNIX_TIMESTAMP(Now());";
  my $ret = $self->MyMySQL->DBH->selectall_arrayref($s);
  $self->LatestTime
    ($ret->[0]->[0]);
  $self->LastHour(7 * 24);
  $self->EarliestTime
    ($self->LatestTime - $self->LastHour * 3600);
  print Dumper
    ({
      LatestTime => $self->LatestTime,
      LastHour => $self->LastHour,
      EarliestTime => $self->EarliestTime,
     });
  $s = "select ID, UNIX_TIMESTAMP(Date) from messages where Sender='UniLang-Client' and UNIX_TIMESTAMP(Date) > ".
    $self->EarliestTime;
  $ret = $self->MyMySQL->Do
    (Statement => $s);
  my @times;
  foreach my $key (sort {$ret->{$a}->{'UNIX_TIMESTAMP(Date)'}
			   <=> $ret->{$b}->{'UNIX_TIMESTAMP(Date)'}} keys %$ret) {
    push @times, $ret->{$key}->{'UNIX_TIMESTAMP(Date)'};
  }
  $self->Times(\@times);
}

sub LoadTimes {
  my ($self, %args) = @_;
  my $c = `cat $file`;
  my $e = eval $c;
  $self->Times($e);
}

sub SaveTimes {
  my ($self, %args) = @_;
  my $OUT;
  open(OUT,">$file") or die "Cannot open file\n";
  print OUT Dumper($self->Times);
  close(OUT);
}

sub Save {
  my ($self, %args) = @_;
  my $OUT;
  my $file = $args{File};
  my $contents = $args{Contents};
  open(OUT,">$file") or die "Cannot open file\n";
  print OUT $contents;
  close(OUT);
}

sub GenerateBins {
  my ($self, %args) = @_;
  Message(Message => "Generating bins...");
  my $bins = [];
  foreach my $t (@{$self->Times}) {
    my $i = ($t - $self->EarliestTime)/3600;
    if (! defined $bins->[$i]) {
      $bins->[$i] = 1;
    } else {
      $bins->[$i] = $bins->[$i] + 1;
    }
  }
  foreach my $i (0..((scalar @$bins)-1)) {
    if (! defined $bins->[$i]) {
      $bins->[$i] = 0;
    }
  }
  $self->Bins($bins);
}

sub Plot {
  my ($self, %args) = @_;
  my $gnuplot = System::GnuPlot->new;
  my $df = "/tmp/manager-sleep-times.csv";
  my $c = join("\n",@{$self->Bins});
  $self->Save
    (File => $df,
     Contents => $c);
  $gnuplot->Plot
    (Command => "plot [x=0:".$self->LastHour."] [0:20] \"$df\" with boxes");
}

sub FitSleep {
  my ($self, %args) = @_;
  Message(Message => "Fitting sleep...");
  # based  on these patterns,  fit a  sleep pattern,  and use  this to
  # predict when I will fall asleep  not that there will be times that
  # I don't  get up  in the morning,  etc.  That information  can over
  # time help to build more accurate models as well

  # print $self->LastHour."\n";

  # get the last time point and start from there
  # my $errors = [];
  my $min = 9999999;
  my $offset = -1;
  my $params;
  foreach my $k (-5..5) {
    my $sleepwidth = $k/5.0+8;
    foreach my $j (-5..5) {
      my $spacing = $j/2.5+24;
      foreach my $i (0..24) {
	my $bedtime = $self->LastHour + $i;
	my $res = $self->CalculateError
	  (BedTime => $bedtime,
	   Spacing => $spacing,
	   SleepWidth => $sleepwidth);
	# print "$i -- $res\n";
	if ($res < $min) {
	  $min = $res;
	  $params = {
		     Spacing => $spacing,
		     SleepWidth => $sleepwidth,
		     BedTime => $bedtime,
		    };
	}
      }
    }
  }
  $params->{BedTimeEpoch} = ($params->{BedTime} * 3600) + $self->EarliestTime;
  $params->{AwakeTimeEpoch} = (($params->{BedTime} + $params->{SleepWidth}) * 3600)
    + $self->EarliestTime;
  $self->Params($params);
  return $params;
}

sub DisplayParams {
  my ($self, %args) = @_;
  # print $offset."\n";
  my $params = $self->Params;
  if ($params->{BedTime} > 0) {
    my $date1 = $self->GetTimeFromEpoch
      (Epoch => $params->{BedTimeEpoch});
    my $date2 = $self->GetTimeFromEpoch
      (Epoch => $params->{AwakeTimeEpoch});
    print "Bedtime:\t$date1\n";
    print "Awake:\t\t$date2\n";
    print Dumper($params);
  }
}

sub GetTimeFromEpoch {
  my ($self, %args) = @_;
  my $dt = DateTime->from_epoch
    (epoch => $args{Epoch},
     time_zone => 'America/New_York');
  return $dt->ymd." ".$dt->hms()." :: ".$dt->epoch;
}

sub CalculateError {
  my ($self, %args) = @_;
  # there are two parameters
  # sleep width, and spacing (assume a spacing of around 25), offset
  # then fit this to the data
  my $offset = $args{Offset};
  my $error = 0;
  foreach my $bin (0..($self->LastHour-1)) {
    my $mask = $self->GetMask
      (Spacing => $args{Spacing},
       SleepWidth => $args{SleepWidth},
       BedTime => $args{BedTime},
       Hour => $bin);
    $error += $self->Bins->[$bin] * $mask;
    # print Dumper($self->Bins->[$bin],$mask,$error);
  }
  return $error;
}

sub GetMask {
  my ($self, %args) = @_;
  my $b = $args{BedTime};
  my $s = $args{Spacing};
  my $w = $args{SleepWidth};
  my $h = $args{Hour};
  # return 2-cos(x/(25/2*0.314159));
  my $gens = (($b - $h) / $s);
  my $diff = $gens - int($gens);
  if ($diff > 1 - $w / $s) {
    return 1;
  } else {
    return 0;
  }
}

1;
