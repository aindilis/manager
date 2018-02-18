sub PlotTaskContextTrends {
  my ($self, %args) = @_;
  # print Dumper($self->Contents);
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
  foreach my $c (@{$self->Contents}) {
    $events->{$cnt} = $c->[1];
    foreach my $task (keys %$log) {
      $log->{$task}->{$cnt} = $score->{$task} * $avg;
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
    if ($ddt) {
      $avg = $dds / $ddt;
    } else {
      $avg = 0;
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
      if ($c->[0] eq "opened") {
	$score->{$task} += 1;
      } elsif ($c->[0] eq "closed") {
	$score->{$task} += -1;
      }
    }

    foreach my $task (keys %$log) {
      $log->{$task}->{$cnt} = $score->{$task} * $avg;
    }
    ++$cnt;
  }
  # plot all tasks together
  # this data is mainly so that manager / score knows what is being
  # worked on, to determine whether it is on task?

  # so, what else can we do?  now we have activity information.  So I suggest we just use line plotting
  my $OUT;
  open(OUT, ">/tmp/context") or die "ouch\n";
  foreach my $event (sort {$a <=> $b} keys %$events) {
    my @l = ($events->{$event});
    foreach my $task (keys %$log) {
      if (exists $log->{$task}->{$event}) {
	push @l, $log->{$task}->{$event};
      } else {
	push @l, 0;
      }
    }
    print OUT join("\t",@l)."\n";
  }
  close(OUT);
}
