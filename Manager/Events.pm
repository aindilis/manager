package Manager::Events;

use BOSS::Config;
use Manager::Dialog qw(Message QueryUser SubsetSelect);
use MyFRDCSA;
use System::GnuPlot;
use PerlLib::MySQL;

use Data::Dumper;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       => [ qw / Config EventMatrix MyGnuPlot MyMySQL MyPray / ];

sub init {
  my ($self,%args) = @_;
  my $c = `cat $UNIVERSAL::systemdir/data/eventmatrix.pl`;
  my $eventmatrix = eval $c;
  $self->EventMatrix
    ($eventmatrix);
  $self->MyGnuPlot
    (System::GnuPlot->new());
  $self->MyMySQL
    (PerlLib::MySQL->new
     (DBName => "score"));
}

sub Execute {
  my ($self,%args) = @_;
  my $conf = $UNIVERSAL::manager->Config->CLIConfig;
  if (exists $conf->{'-c'} or $self->Config->IsEmpty) {
    print Dumper($self->EventMatrix);
    $self->RecordEvents
      (Hash => $self->EventMatrix);
  }
  if (exists $conf->{'-k'}) {
    $self->SpotCheck;
  }
  if (exists $conf->{'-d'}) {
    Message
      (Message =>
       "Current score for today is: <".
       Dumper($self->GetDailyScores
	      (Date => "Now()")).">");
  }
  if (exists $conf->{'-p'}) {
    $self->PlotRecentScores
      (OutputFormat => $conf->{-j} ? "jpeg" : undef,
       OutputFile => $conf->{-j} ? $conf->{-j} : undef);
  }
  if (exists $conf->{'-P'}) {
    $self->PlotDailyScores
      (OutputFormat => $conf->{-j} ? "jpeg" : undef,
       OutputFile => $conf->{-j} ? $conf->{-j} : undef);
  }
  if (exists $conf->{'-s'}) {
    $self->ShowRecentEvents;
  }
}

sub ChooseEvent {
  my ($self,%args) = @_;
  my $chash = $args{Hash};
  my $order = $args{Order};
  my @events;
  my @res;

  if (defined $order) {
    @events = SubsetSelect
      (Set => [sort {$order->{$b} <=> $order->{$a}} keys %$chash],
       Selection => {},
       Desc => $order);
    @events = sort {$order->{$b} <=> $order->{$a}} @events;
  } else {
    @events = SubsetSelect
      (Set => [sort keys %$chash],
       Selection => {});
    @events = sort @events;
  }
  foreach my $event (@events) {
    if (ref $chash->{$event} eq "HASH") {
      # recurse
      if (defined $order) {
	push @res, @{$self->ChooseEvent
		       (Hash => $chash->{$event},
			Order => $order)};
      } else {
	push @res, @{$self->ChooseEvent
		       (Hash => $chash->{$event})};
      }
    } else {
      print "$event\n";
      push @res, [$event,$chash->{$event},QueryUser("How many times?")];
    }
  }
  return \@res;
}

sub RecordEvents {
  my ($self,%args) = @_;
  my $agentid = 0;
  my $eventsets = $self->ChooseEvent
    (Hash => $args{Hash},
     Order => $args{Order});
  foreach my $eventset (@$eventsets) {
    my $count = $eventset->[2];
    # print "<$count>\n";
    if ($count =~ /^\d+$/ and $count > 0) {
      my $statement =
	"insert into events values (NULL,'$agentid',now(),".
	  $self->MyMySQL->Quote($eventset->[0]).",".
	    $self->MyMySQL->Quote($eventset->[1]).",".
	      $self->MyMySQL->Quote($count).");";
      print $statement."\n";
      $self->MyMySQL->Do
	(Statement => $statement);
    }
  }
}

sub GetOverallScoreAtDate {
  my ($self,%args) = @_;
  return 0;
}

sub GetDailyScores {
  my ($self,%args) = @_;
  my $date = $args{Date};
  my $statement = "select ID,Score,Count from events where Date_Format(Date,\"\%Y-\%m-\%d\")=Date_Format($date,\"\%Y-\%m-\%d\");";
  print $statement."\n";
  my $ref = $self->MyMySQL->Do
    (KeyField => "ID",
     Statement => $statement);
  my $score =
    {Good => 0,
     Bad => 0};
  foreach my $key (keys %$ref) {
    $score->{$ref->{$key}->{Score} > 0 ? "Good" : "Bad"} += $ref->{$key}->{Score} * $ref->{$key}->{Count};
  }
  $score->{Sum} = $score->{Good} + $score->{Bad};
  return $score;
}

sub ShowRecentEvents {
  my ($self,%args) = @_;
  my $statement = "select ID,Date,UNIX_TIMESTAMP(Date),Event,Count,Score from events;";
  print $statement."\n";
  my $ref = $self->MyMySQL->Do
    (KeyField => "ID",
     Statement => $statement);
  my $tscore = 0;
  foreach my $key (sort
		   {$ref->{$a}->{"UNIX_TIMESTAMP(Date)"} <=>
		      $ref->{$b}->{"UNIX_TIMESTAMP(Date)"}}
		   keys %$ref) {
    print join("\t",
	       ($ref->{$key}->{Date},
		$ref->{$key}->{Count},
		$ref->{$key}->{Score},
		$ref->{$key}->{Event},
	       ))."\n";
  }
  return $tscore;
}

sub PlotRecentScores {
  my ($self,%args) = @_;
  # select them, write to a file, and plot with gnuplot
  my $date = $args{Date};
  my $statement = "select ID,Score,UNIX_TIMESTAMP(Date) from events;";
  print $statement."\n";
  my $ref = $self->MyMySQL->Do
    (Statement => $statement);
  my $tscore = $self->GetOverallScoreAtDate
    (Date => $date);
  my $OUT;
  my $df = "/tmp/manager.gnuplot";
  open(OUT,">$df") or die "Cannot open $df\n";
  foreach my $key (sort
		   {$ref->{$a}->{"UNIX_TIMESTAMP(Date)"} <=>
		      $ref->{$b}->{"UNIX_TIMESTAMP(Date)"}}
		   keys %$ref) {
    # print Dumper($ref);
    # convert the date to a linear time
    $tscore += $ref->{$key}->{Score};
    print OUT join("\t",
		   ($ref->{$key}->{"UNIX_TIMESTAMP(Date)"}/86400.0,
		    $ref->{$key}->{Score},
		    $tscore))."\n";
  }
  close(OUT);

  $self->MyGnuPlot->Plot
    (OutputFormat => $args{OutputFormat},
     OutputFile => $args{OutputFile},
     Command => "plot \"$df\" using 1:3 with lines",
     Wait => $args{OutputFormat} ? 0 : 100);
}

sub PlotDailyScores {
  my ($self,%args) = @_;
  my $OUT;
  my $window = 20;
  my $df = "/tmp/manager.gnuplot";
  open(OUT,">$df") or die "Cannot open $df\n";
  foreach my $i (0..$window) {
    my $score = $self->GetDailyScores
      (Date => "DATE_SUB(Now(), INTERVAL $i DAY)");
    print OUT join("\t",($window - $i,$score->{Good},$score->{Bad},
			 $score->{Sum}))."\n";
  }
  close(OUT);

  my @cp =
    (
     "plot",
     # "[".($maxx - $window).":$maxx]",
     # "[0:".($maxy*1.1)."]",
    );
  my @l;
  my $i = 2;
  foreach my $item (qw(Good Bad Sum)) {
    my @m =
      (
       "'/tmp/manager.gnuplot'",
       "using 1:$i",
       "t",
       "\"$item\"",
       "lw 3",
       # "smooth csplines",
       "with boxes",
      );
    ++$i;
    push @l, join(" ",@m);
  }
  push @cp, join(",",@l);
  push @cp, (
	    );
  my $com = join(" ",@cp);
  print "$com\n";

  # Manager::Records::Context

  $self->MyGnuPlot->Plot
    (OutputFormat => $args{OutputFormat},
     OutputFile => $args{OutputFile},
     Command => $com, #"plot \"$df\" using 1:2 with boxes",
     Wait => $args{OutputFormat} ? 0 : 100);
}

sub SpotCheck {
  my ($self,%args) = @_;
  # for now simple frequency
  my $s = "select ID,Date,Event,Count,Score from events";
  my $ret = $self->MyMySQL->Do(Statement => $s);
  my $order = {};
  my $hash = {};
  my $order2 = {};
  my $hash2 = {};
  foreach my $key (keys %$ret) {
    my $event = $ret->{$key}->{Event};
    my $count = $ret->{$key}->{Count};
    if (exists $order->{$event}) {
      $order->{$event} += $count;
    } else {
      $order->{$event} = $count;
      $hash->{$event} = $ret->{$key}->{Score};
    }
  }
  my @sortedkeys = sort {$order->{$b} <=> $order->{$a}} keys %$order;
  foreach my $event (splice(@sortedkeys,0,15)) {
    $order2->{$event} = $order->{$event};
    $hash2->{$event} = $hash->{$event};
  }
  $self->RecordEvents
    (Hash => $hash2,
     Order => $order2)
}

1;
