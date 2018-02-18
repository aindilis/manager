package Manager::Records::Context;

use Manager::Dialog qw (ApproveCommands Message QueryUser SubsetSelect);
use Manager::Records::Context::TaskManager;
use PerlLib::MySQL;
use System::GnuPlot;
use System::GnuPlot::Command;

use Data::Dumper;
use Text::Wrap;
use WWW::Mechanize;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / MyMySQL MyUnilang EpochStartWindow EpochEndWindow Thresholds MyTaskManager Debug /

  ];

sub init {
  my ($self, %args) = @_;
  $self->Debug(1);
  $self->Thresholds({
		    TaskEntropy => 2,
		    TaskJointEntropy => 2,
		    Productivity => 100
		   });
  $self->MyMySQL
    (PerlLib::MySQL->new
     (DBName => "elog"));
}

sub GetScore {
  my ($a, $b) = @_;
  my $tmp = 1+($a * $b)/(60 * 4.5);
  return log($tmp) if ($tmp > 0);
  return 0;
  # return $a * $b / (60 * 4.5);
}

sub GetTime {
  my ($epoch) = @_;
  return $epoch / 3600.0;
}

sub SelectWindow {
  my ($self, %args) = @_;
  my $window = $args{Window};
  # FIXME GET RID OF THIS STUPID + "3600" hack
  $self->EpochEndWindow
    ($args{Epoch} || $self->MyMySQL->Do
     (Statement => "select UNIX_TIMESTAMP(Now())")->[0]->[0] + "3600");
  $self->EpochStartWindow($self->EpochEndWindow - 3600 * $window);
  my $statement = "select *,UNIX_TIMESTAMP(Date) from events where sender='Emacs-Client' and ".
    "UNIX_TIMESTAMP(Date) > ".$self->EpochStartWindow.
      " and UNIX_TIMESTAMP(Date) < ".$self->EpochEndWindow;
  # Message(Message => $statement);
  my $ret = $self->MyMySQL->Do
    (Statement => $statement);
  my @keys = sort {$ret->{$a}->{"UNIX_TIMESTAMP(Date)"} <=>
		     $ret->{$b}->{"UNIX_TIMESTAMP(Date)"}}
    keys %$ret;
  return [$ret,\@keys];
}

sub GetEvent {
  my ($self, $value) = @_;
  my @res = split /::/,$value->{Contents};
  return [$res[0],$value->{"UNIX_TIMESTAMP(Date)"},$res[1],$res[2],$res[3]];
}

sub PlotTaskContextTrends {
  my ($self, %args) = @_;
  # select all the events we need to look
  my $window = 2.5; # 24 * 7 * 4; # 2.5;
  my $log = {};
  my $score = {};
  my $events = {};
  my $ts = 0;
  my $ds = 0;
  my $dt = 0;
  my $lts = 0;
  my $lds = 0;
  my $ldt = 0;
  my $avg = 0;
  my $cnt = 0;
  my $maxx = 0;
  my $maxy = 0;
  my $w = $self->SelectWindow
    (Epoch => $args{Epoch},
     Window => $window);
  my $ret = $w->[0];
  my $keys = $w->[1];
  foreach my $key (@$keys) {
    my $value = $ret->{$key};
    my $time = GetTime($value->{"UNIX_TIMESTAMP(Date)"});
    if ($time > $maxx) {
      $maxx = $time;
    }
    my $c = $self->GetEvent($value);
    # print Dumper($c);
    $events->{$cnt} = $time; #$c->[1];
    foreach my $task (keys %$log) {
      $log->{$task}->{$cnt} = GetScore($score->{$task},$avg);
      if ($log->{$task}->{$cnt} > $maxy) {
	$maxy = $log->{$task}->{$cnt};
      }
    }

    $lts = $ts;
    $lds = $ds;
    $ldt = $dt;
    $ts = $c->[3];
    $ds = $c->[4];
    $dt = $c->[1];
    $dts = $ts - $lts;
    $dds = $ds - $lds;
    $ddt = $dt - $ldt;
    if ($dds and $ddt) {
      $avg = $dds / $ddt;
    } else {
      $avg = 1;
    }

    # print $dds."\n";

    my $f = $c->[2];
    my $tasks = $self->LookupTasksForFile
      (File => $f);
    # how to plot multiple lines in gnuplot?

    foreach my $task (keys %$tasks) {
      if (! exists $log->{$task}) {
	$log->{$task} = {};
	$score->{$task} = 0;
      }
      if ($c->[0] eq "display") {
	$score->{$task} += 1;
      } elsif ($c->[0] eq "conceal") {
	$score->{$task} += -1 if $score->{$task} > 0;
      }
    }
    ++$cnt;
    if (1) {
      $events->{$cnt} = $time; #$c->[1];
      foreach my $task (keys %$log) {
	$log->{$task}->{$cnt} = GetScore($score->{$task},$avg);
	if ($log->{$task}->{$cnt} > $maxy) {
	  $maxy = $log->{$task}->{$cnt};
	}
      }
      ++$cnt;
    }
  }
  # plot all tasks together
  # this data is mainly so that manager / score knows what is being
  # worked on, to determine whether it is on task?

  if ($args{Mode} eq "Check") {
    my $wtd = {};
    my $ctime = GetTime($self->EpochEndWindow);
    foreach my $task (keys %$log) {
      foreach my $cnt (keys %{$log->{$task}}) {
	$wtd->{$task} += $log->{$task}->{$cnt} * (1 - ($ctime - $events->{$cnt})/$window);
      }
    }
    return $wtd;
  }

  # so, what else can we do?  now we have activity information.  So I suggest we just use line plotting
  my $OUT;
  open(OUT, ">/tmp/context") or die "ouch\n";
  my @idx = sort keys %$log;
  print Dumper(\@idx);
  foreach my $event (sort {$a <=> $b} keys %$events) {
    my @l = ($events->{$event});
    foreach my $task (@idx) {
      if (exists $log->{$task}->{$event}) {
	push @l, $log->{$task}->{$event};
      } else {
	push @l, 0;
      }
    }
    print OUT join("\t",@l)."\n";
  }
  close(OUT);
  # now plot
  my $gnuplot = System::GnuPlot->new();
  my $i = 2;
  # plot "/tmp/context" using 1:2 with filledcurve closed, "/tmp/context" using 1:3 with filledcurve closed, "/tmp/context" using 1:4 with filledcurve closed
  my @cp =
    (
     "plot",
     "[".($maxx - $window).":$maxx]",
     "[0:".($maxy*1.1)."]",
    );
  my @l;
  foreach my $task (@idx) {	#splice (@idx,0,2)) {
    my @m =
      (
       "'/tmp/context'",
       "using 1:$i",
       "t",
       "\"$task\"",
       "lw 3",
       # "smooth csplines",
       "with lines",
      );
    ++$i;
    push @l, join(" ",@m);
  }
  push @cp, join(",",@l);
  push @cp, (
	    );
  my $com = join(" ",@cp);
  print "$com\n";
  $gnuplot->Plot
    (OutputFormat => $args{OutputFormat},
     OutputFile => $args{OutputFile},
     Command => $com,
     Wait => $args{OutputFormat} ? 0 : 100);
}

sub LookupTasksForFile {
  my ($self, %args) = @_;
  if (! $self->MyTaskManager) {
    $self->MyTaskManager(Manager::Records::Context::TaskManager->new());
  }
  return $self->MyTaskManager->GetTasksForFile(File => $args{File});
}

sub Measures {
  my ($self, %args) = @_;
  my $res = $self->ComputeMeasures();
  my $measures = $res->{Measures};
  my $maxs = $res->{MaxMeasureNameLength};
  foreach my $measure (keys %$measures) {
    if ($measures->{$measure} > $self->Thresholds->{$measure}) {
      Message(Message => sprintf("[PASS] %-${maxs}s = %2.10f > %2.10f",
				 $measure,
				 $measures->{$measure},
				 $self->Thresholds->{$measure}));
    } else {
      Message(Message => sprintf("[FAIL] %-${maxs}s = %2.10f < %2.10f",
				 $measure,
				 $measures->{$measure},
				 $self->Thresholds->{$measure}));
    }
  }
  return {
	  Measures => $measures,
	  Thresholds => $self->Thresholds
	 };
}

sub ComputeMeasures {
  my ($self, %args) = @_;
  my $wtd = $self->PlotTaskContextTrends
    (Mode => "Check",
     Epoch => $args{Epoch});
  my $measures = {};
  my $maxs = 0;
  foreach my $measure (keys %{$self->Thresholds}) {
    if (length($measure) + 1 > $maxs) {
      $maxs = length($measure) + 1;
    }
    $measures->{$measure} = $self->$measure($wtd);
  }
  return {Measures => $measures,
	  MaxMeasureNameLength => $maxs};
}

sub TaskEntropy {
  my ($self, $wtd) = @_;
  my $sum = 0;
  foreach my $k (keys %$wtd) {
    $sum += $wtd->{$k};
  }
  my $entropy = 0;
  if ($sum > 0) {
    foreach my $k (keys %$wtd) {
      $p = $wtd->{$k} / $sum;
      if ($p > 0) {
	$entropy += $p * -log($p)/log(2);
      }
    }
  }
  return $entropy;
}

sub TaskJointEntropy {
  my ($self, $wtd) = @_;
  # see how closely the tasks align with a given task alignment
  my $ta = {
	    'svrs' => '0.892538813777906',
	    'architect' => '3.49148066416676e-05',
	    'manager' => '168.491245381256',
	   };
  foreach my $k (keys %$wtd) {
    $ta->{$k} = 0 if ! exists $ta->{$k};
  }
  foreach my $k (keys %$ta) {
    $wtd->{$k} = 0 if ! exists $wtd->{$k};
  }
  foreach my $k (keys %$wtd) {
    # I forget how to calculate joint entropy
    # need the internet!
  }
  return 0;
}

sub Productivity {
  my ($self, $wtd) = @_;
  my $sum = 0;
  foreach my $k (keys %$wtd) {
    $sum += $wtd->{$k};
  }
  return $sum;
}

sub PlotMeasures {
  my ($self, %args) = @_;
  my $epoch = $self->MyMySQL->Do
    (Statement => "select UNIX_TIMESTAMP(Now())")->[0]->[0];
  my $window = 24*3600;
  my $bins = 48;
  my $mymeasures = {};
  my $OUT;
  open(OUT, ">/tmp/measures") or die "ouch\n";
  foreach my $i (0..$bins) {
    my $cepoch = $epoch - ($window/$bins)*($bins - $i);
    my $ret = $self->ComputeMeasures
      (Epoch => $cepoch);
    my $measures = $ret->{Measures};
    my $maxs = $ret->{MaxMeasureNameLength};
    # print Dumper($measures);
    my @l = ($cepoch);
    foreach my $key (sort keys %$measures) {
      $mymeasures->{$key} = 1;
      push @l, $measures->{$key} > 0 ? sqrt($measures->{$key}) : 0;
    }
    print OUT join("\t",@l)."\n";
  }
  close(OUT);

  # now plot
  my $gnuplot = System::GnuPlot->new();
  my $com = System::GnuPlot::Command->new
    (Table => [sort keys %$mymeasures]);
  $gnuplot->Plot
    (OutputFormat => $args{OutputFormat},
     OutputFile => $args{OutputFile},
     Command => $com->SPrint,
     Wait => $args{OutputFormat} ? 0 : 100);
}

sub GenerateTimesheetLogForMonth {
  my ($self, %args) = @_;
  my $year = "2006";
  my $month = $args{Month};
  my $days = {
	      "01" => 31,
	      "02" => 29,
	      "03" => 31,
	      "04" => 30,
	      "05" => 31,
	      "06" => 30,
	      "07" => 31,
	      "08" => 31,
	      "09" => 30,
	      "10" => 31,
	      "11" => 30,
	      "12" => 31,
	     };
  my $num = $days->{$month};
  foreach my $dayn (1..$num) {
    my $day = sprintf "%4d-%02d-%02d",$year,$month,$dayn;
    $self->GenerateTimesheetLogForDay(Day => $day);
  }
}

sub GenerateTimesheetLogForDay {
  my ($self, %args) = @_;
  my $day = $args{Day};

  # now do the lookup in the  table for that day, extract the required
  # information and put that into a timesheet record
  # e.g. day has to be like 2006-07-11

  # select all the events we need to look
  my $log = {};
  my $score = {};
  my $events = {};
  my $ts = 0;
  my $ds = 0;
  my $dt = 0;
  my $lts = 0;
  my $lds = 0;
  my $ldt = 0;
  my $avg = 0;
  my $cnt = 0;
  my $maxx = 0;
  my $maxy = 0;

  my $statement = "select *,UNIX_TIMESTAMP(Date) from events where sender='Emacs-Client' and Date like '$day\%';";
  my $ret = $self->MyMySQL->Do(Statement => $statement);

  my @keys2 = sort {$ret->{$a}->{"UNIX_TIMESTAMP(Date)"} <=>
		      $ret->{$b}->{"UNIX_TIMESTAMP(Date)"}} keys %$ret;
  my $keys = \@keys2;

  if (! @keys2) {
    print "No data, either logging was not running or user was absent.\n";
    return;
  }

  my $timein = $ret->{$keys2[0]}->{'Date'};
  $timein =~ s/^.*? //;
  my $timeout = $ret->{$keys2[-1]}->{'Date'};
  $timeout =~ s/^.*? //;

  foreach my $key (@$keys) {
    my $value = $ret->{$key};
    my $time = GetTime($value->{"UNIX_TIMESTAMP(Date)"});
    if ($time > $maxx) {
      $maxx = $time;
    }
    my $c = $self->GetEvent($value);
    # print Dumper($c);
    $events->{$cnt} = $time;	#$c->[1];
    foreach my $task (keys %$log) {
      $log->{$task}->{$cnt} = GetScore($score->{$task},$avg);
      if ($log->{$task}->{$cnt} > $maxy) {
	$maxy = $log->{$task}->{$cnt};
      }
    }

    $lts = $ts;
    $lds = $ds;
    $ldt = $dt;
    $ts = $c->[3];
    $ds = $c->[4];
    $dt = $c->[1];
    $dts = $ts - $lts;
    $dds = $ds - $lds;
    $ddt = $dt - $ldt;
    if ($dds and $ddt) {
      $avg = $dds / $ddt;
    } else {
      $avg = 1;
    }

    # print $dds."\n";

    my $f = $c->[2];
    my $tasks = $self->LookupTasksForFile
      (File => $f);
    # how to plot multiple lines in gnuplot?

    foreach my $task (keys %$tasks) {
      if (! exists $log->{$task}) {
	$log->{$task} = {};
	$score->{$task} = 0;
      }
      if ($c->[0] eq "display") {
	$score->{$task} += 1;
      } elsif ($c->[0] eq "conceal") {
	$score->{$task} += -1 if $score->{$task} > 0;
      }
    }
    ++$cnt;
    if (1) {
      $events->{$cnt} = $time;	#$c->[1];
      foreach my $task (keys %$log) {
	$log->{$task}->{$cnt} = GetScore($score->{$task},$avg);
	if ($log->{$task}->{$cnt} > $maxy) {
	  $maxy = $log->{$task}->{$cnt};
	}
      }
      ++$cnt;
    }
  }
  # plot all tasks together
  # this data is mainly so that manager / score knows what is being
  # worked on, to determine whether it is on task?

  # so, what else can we do?  now we have activity information.  So I suggest we just use line plotting
  my @idx = sort keys %$log;
  # print Dumper(\@idx);
  my @results;
  foreach my $event (sort {$a <=> $b} keys %$events) {
    my @l = ($events->{$event});
    foreach my $task (@idx) {
      if (exists $log->{$task}->{$event}) {
	push @l, $log->{$task}->{$event};
      } else {
	push @l, 0;
      }
    }
    push @results, \@l;
  }

  # now process the final time results into a summary of time and effort spent
  my $res = {};
  my $totalactivetime = 0;
  my $totaleffort = 0;
  foreach my $l (@results) {
    my @lines = @{$l};
    my $time = shift @lines;
    if (! $lasttime) {
      $lasttime = $time;
    }
    foreach my $e (@idx) {
      if (defined $e) {
	$h->{$time}->{$e} = shift @lines;
	$res->{$e}->{Effort} += $h->{$time}->{$e};
	$totaleffort += $h->{$time}->{$e};
	my $deltatime = $time - $lasttime;
	if ($h->{$time}->{$e} > 0) {
	  $res->{$e}->{Time} += $deltatime;
	  $totalactivetime += $deltatime;
	}
      }
    }
    $lasttime = $time;
  }

  # figure out which day that was
  # print out the most done tasks and relate

  # total time is calculated from start and end time

  $day =~ /\d{2}(\d{2})-(\d{2})-(\d{2})/;
  my $date_entered = "$2/$3/$1";

  $timeout =~ /(\d{2}):(\d{2}):(\d{2})/;
  my $secondsout = $1 * 3600 + $2 * 60 + $3;
  $timeout = "$1:$2";

  $timein =~ /(\d{2}):(\d{2}):(\d{2})/;
  my $secondsin = $1 * 3600 + $2 * 60 + $3;
  $timein = "$1:$2";

  my $seconds = $secondsout - $secondsin;
  my $totalhours = $seconds / 3600;

  my $hours = int($seconds / 3600);
  $seconds = $seconds - $hours * 3600;
  my $minutes = int($seconds / 60);
  $seconds = $seconds - $minutes * 60;
  my $totaltime = "$hours:$minutes:$seconds";
  if ($totalhours > 10) {
    $totalhours = 10;
  }
  $totalhours = sprintf("%3.2f",$totalhours);

  my $activitysummary = sprintf("Total Time: %3.2f hours\nCoding Time: %3.2f hours\nTotal Coding Effort: %3.2f\n\n",$totalhours,$totalactivetime,$totaleffort);
  foreach my $key (Top($res)) {
    $activitysummary .= sprintf "%-20s : %3.2f hours, %3.2f effort\n",$key,$res->{$key}->{Time},$res->{$key}->{Effort};
  }
  # $activitysummary .= "\nTime is measured between the time of the first and last Emacs activity for the day.Effort is measured in relation to keystrokes and.\n";

  # now get the description for this day
  my $accomplishedtasks = $self->GetAccomplishedTasks(Day => $day);
  my $description = $activitysummary ."\n\n". $accomplishedtasks;

  my $form = {
	      job_id => 18084,
	      date_entered => $date_entered,
	      total_hours => $totalhours,
	      time_in => $timein,
	      time_out => $timeout,
	      billable => "no",
	      hours_description => $description,
	     };
  if ($self->Debug) {
    print Dumper($form) if $self->Debug;
  } else {
    return $self->SubmitForm(Form => $form);
  }
}

sub Top {
  my $res = shift;
  my $h = {};
  foreach my $key (keys %$res) {
    if (exists $res->{$key}->{Effort} and $res->{$key}->{Time}) {
      $h->{$key} = $res->{$key};
      $h->{$key}->{Total} = $h->{$key}->{Time} * $h->{$key}->{Effort};
    }
  }
  my @l = sort {$h->{$b}->{Total} <=> $h->{$a}->{Total}} keys %$h;
  return splice @l, 0, 5;
}

sub LogHours {
  my ($self, %args) = @_;
  # list the days for which we have not logged hours
  # list the last day which we have logged hours
  my $logged = {};
  my $file = "/var/lib/myfrdcsa/codebases/internal/manager/data/emacs-logs/timesheet/logged.pl";
  if (-f $file) {
    $logged = eval `cat "$file"`;
  }

  my $statement = "select distinct(Date(Date)) from events where sender='Emacs-Client' and Date > '2006-05-05';";
  my $res = $self->MyMySQL->DBH->selectall_arrayref($statement);

  my @a;
  foreach my $ref (@$res) {
    if (! exists $logged->{$ref->[0]}) {
      push @a, $ref->[0];
    }
  }
  my @b = SubsetSelect(Set => \@a);
  foreach my $day (sort @b) {
    print $day."\n";
    if ($self->GenerateTimesheetLogForDay
	(Day => $day)) {
      $logged->{$day} = 1;
    }
  }

  if (! $self->Debug) {
    my $OUT;
    open(OUT,">$file") or die "can't open out";
    print OUT Dumper($logged);
    close(OUT);
  }
}

sub SubmitForm {
  my ($self, %args) = @_;
  my $form = $args{Form};
  print "Logging form\n";
  print Dumper($form);
  my $mech = WWW::Mechanize->new();
  $mech->get("http://ai.onshore.com/log.html");
  $mech->submit_form
    (
     form_name => 'loghours',
     fields => $form,
    );
  my $content = $mech->content;
  if ($content =~ /Hours Successfully Logged/) {
    print "Success\n";
    return 1;
  } else {
    print "Failure\n";
    return 0;
  }
}

sub GetAccomplishedTasks {
  my ($self, %args) = @_;
  # Pull from the database information on what you accomplished
  # for our little trick we will simply pull for now

  # There is a lot you could do here by correlating tickets and files,
  # etc you could  say which tasks have been worked  on, how much left
  # there  is,   etc,  computing  all  of  that   based  on  estimated
  # difficulty, etc.

  $self->MyUnilang
    (PerlLib::MySQL->new(DBName => "unilang")) if ! $self->MyUnilang;

  my $day = $args{Day};

  my $res = $self->MyUnilang->Do
    (Statement => "select * from messages where Date like '%$day%' and Sender='Unilang-Client'");

  my @accomplished;
  foreach my $key (sort {$a <=> $b} keys %$res) {
    push @accomplished, wrap('',"\t","+ ".$res->{$key}->{Contents});
  }
  return "Tasks Closed:\n\n".join("\n", @accomplished);
}

1;
