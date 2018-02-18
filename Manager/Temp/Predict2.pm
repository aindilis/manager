package Manager::Predict;

# program to estimate sleep periods, among other things, from data

# very easy thing to do, simply create a bounding box fit over time to
# determine  absenses.  First,  however, computer  all  large absenses
# (maybe in a fuzzy way)

use PerlLib::MySQL;
use System::GnuPlot;

use Data::Dumper;
use DateTime;

use File::Stat;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       => [ qw / Bins / ];

sub init {
  my ($self, %args) = @_;
}

sub Execute {
  my ($self, %args) = @_;
  my $update = 0;
  #   if (! -f $file) {
  #     $update = 1;
  #   } else {
  #     my $stat = File::Stat->new
  #       ($file);
  #     print Dumper
  #       ($stat->ctime);
  #     exit(0);
  #   }
  if (1 or $update) {
    RetrieveTimes();
    SaveTimes();
  }
  LoadTimes();
  Strategy2();
  FitSleep();
  Plot();
}

sub RetrieveTimes {
  my ($self, %args) = @_;
  my $mysql = PerlLib::MySQL->new
    (DBName => "unilang");

  my $s = "select ID, UNIX_TIMESTAMP(Date) from messages where Sender='UniLang-Client' and UNIX_TIMESTAMP(Date) > 1133000000";

  my $ret = $mysql->Do
    (Statement => $s);

  foreach my $key (sort {$ret->{$a}->{'UNIX_TIMESTAMP(Date)'}
			   <=> $ret->{$b}->{'UNIX_TIMESTAMP(Date)'}} keys %$ret) {
    push @times, $ret->{$key}->{'UNIX_TIMESTAMP(Date)'};
  }
}

sub SaveTimes {
  my ($self, %args) = @_;
  my $OUT;
  open(OUT,">$file") or die "Cannot open file\n";
  print OUT Dumper(\@times);
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

sub LoadTimes {
  my ($self, %args) = @_;
  my $c = `cat $file`;
  my $e = eval $c;
  @times = @$e;
}

sub Strategy1 {
  my ($self, %args) = @_;
  my @diff;
  my @ediff;
  my $lt;
  my $le;
  foreach my $t (@times) {
    if (! $lt) {
      $lt = $t;
    } else {
      if ($t - $lt > 5 * 3600) {
	# this is a sleep event
	# push @events, $t;
	if (! $le) {
	  $le = $t;
	} else {
	  push @ediff, $t - $le;
	  $le = $t;
	}
      }
      $lt = $t;
    }
  }
  my $gnuplot = System::GnuPlot->new;
  my $df = "temp.csv";
  # my $c = join("\n",@diff);
  my $c = join("\n",@ediff);
  Save
    (File => $df,
     Contents => $c);
  $gnuplot->Plot
    (Command => "plot \"$df\"");
}

sub Strategy2 {
  my ($self, %args) = @_;
  foreach my $t (@times) {
    my $i = ($t - 1133000000)/3600;
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
}

sub Plot {
  my ($self, %args) = @_;
  my $gnuplot = System::GnuPlot->new;
  my $df = "temp.csv";
  my $c = join("\n",@$bins);
  Save
    (File => $df,
     Contents => $c);
  $gnuplot->Plot
    (Command => "plot [x=800:1000] [0:20] \"$df\" with boxes");
}

sub FitSleep {
  my ($self, %args) = @_;
  # based  on these patterns,  fit a  sleep pattern,  and use  this to
  # predict when I will fall asleep  not that there will be times that
  # I don't  get up  in the morning,  etc.  That information  can over
  # time help to build more accurate models as well

  $lasthour = scalar @$bins;
  # print $lasthour."\n";

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
	my $bedtime = $lasthour + $i;
	my $res = CalculateError
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
  # print $offset."\n";
  if ($params->{BedTime} > 0) {
    my $bedtime = GetTimeFromHour
      (Hour => $params->{BedTime});
    my $awaketime = GetTimeFromHour
      (Hour => $params->{BedTime} + $params->{SleepWidth});
    print "Bedtime:\t$bedtime\n";
    print "Awake:\t\t$awaketime\n";
    print Dumper($params);
  }
}

sub GetTimeFromHour {
  my ($self, %args) = @_;
  # calculate the time from the hour value
  # first convert to
  my $epoch = ($args{Hour} * 3600) + 1133000000;
  # now convert from unixsecs to date
  my $dt = DateTime->from_epoch( epoch => $epoch - 5 * 3600 );
  return $dt->ymd." ".$dt->hms()." :: ".$dt->epoch;
}

sub CalculateError {
  my ($self, %args) = @_;
  # there are two parameters
  # sleep width, and spacing (assume a spacing of around 25), offset
  # then fit this to the data
  my $offset = $args{Offset};
  my $error = 0;
  foreach my $bin (($lasthour-200)..($lasthour-1)) {
    my $mask = GetMask
      (Spacing => $args{Spacing},
       SleepWidth => $args{SleepWidth},
       BedTime => $args{BedTime},
       Hour => $bin);
    $error += $bins->[$bin] * $mask;
    # print Dumper($bins->[$bin],$mask,$error);
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
