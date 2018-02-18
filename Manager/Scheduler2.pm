package Manager::Scheduler2;

use Manager::Scheduler2::GoalEditor;
use PerlLib::SwissArmyKnife;

# use Schedule::Cron::Events;
use Schedule::Cron;
use String::ShellQuote;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       => [ qw / CronFile MyCron PID LastLoadTime Context MyGoalEditor / ];

sub init {
  my ($self,%args) = @_;
  # connect to unilang, send a message unilang as needed here
  # don't worry about it performing correctly when it is shut off, for now
  $self->CronFile($args{CronFile} || "/etc/myfrdcsa/manager/crontab");
  $self->Context("Org::FRDCSA::Manager::Scheduler2");
  $self->MyGoalEditor
    (Manager::Scheduler2::GoalEditor->new
     (
      Context => $self->Context,
     ));
}

sub LoadCronFile {
  my ($self,%args) = @_;
  $self->MyCron(Schedule::Cron->new(sub {$self->Dispatcher(@_);}));
  my $cronfile = $self->CronFile;
  print "Loading CronFile $cronfile.\n";
  $self->LastLoadTime(time);
  foreach my $line (split /\n/, `cat "$cronfile"`) {
    if ($line =~ /^\s*\#/) {
      # comment line
    } elsif ($line =~ /^(.+?)\s+(\{.*\})\s*$/) {
      my $datespec = $1;
      my $data = $2;
      my $VAR1 = undef;
      eval "\$VAR1 = $data;";
      my %data2 = %$VAR1;
      $VAR1 = undef;

      # now we needs must calculate the revised information datespecs
      my $newdatespec = $self->CalculateNewDateSpec
	(
	 DateSpec => $datespec,
	 Arguments => \%data2,
	);
      if (defined $newdatespec) {
	$self->MyCron->add_entry($newdatespec, arguments => \%data2);
      } else {
	print "ERROR $datespec\n";
	$self->MyCron->add_entry($datespec, arguments => \%data2);
      }
    }
  }
}

sub CalculateNewDateSpec {
  my ($self,%args) = @_;
  my $due = $args{Arguments}->{WarningTime};
  my %hash = ();
  foreach my $entry (split /,\s*/, $due) {
    my ($qty,$unit) = split /\s+/, $entry;
    $hash{$unit} = $qty;
  }
  if (keys %hash) {
    my $duration = DateTime::Duration->new
      (%hash);
    # so using this duration, calculate the revised datespec
    my $datespec = $args{DateSpec};
    # just run it through the entries prediction for several times, and recalculate
    # print Dumper([$datespec,$due]);
    my ($minutes, $hours, $idk1s, $idk2s, $dayofweeks) = split /\s+/,$datespec;
    my $now = DateTime->now;
    my $res;
    foreach my $minute (GetNumbers(Minutes => $minutes)) {
      foreach my $hour (GetNumbers(Hours => $hours)) {
	foreach my $dayofweek (GetNumbers(DOW => $dayofweeks)) {
	  my $duration2 = DateTime::Duration->new
	    (
	     # years   => 3,
	     # months  => 5,
	     # weeks   => 1,
	     days    => $dayofweek,
	     hours   => $hour,
	     minutes => $minute,
	    );
	  my $newduration = $duration2 - $duration;
	  my $newtime = $now + $newduration;
	  $newduration = $newtime - $now;

	  if ($newduration->is_negative) {
	    # there is an error somewhere here
	    my $oneweek = DateTime::Duration->new( weeks => 1 );
	    $newduration = $newduration + $oneweek;
	    $newtime = $now + $newduration;
	    $newduration = $newtime - $now;
	  }

	  # now calculate the resulting items
	  my $minutes = $newduration->{minutes};
	  my $min = $minutes % 60;
	  $res->{minutes}->{$min} = 1;

	  my $hour = int($minutes / 60.0);
	  $res->{hours}->{$hour} = 1;

	  $res->{days}->{$newduration->{days}} = 1;

	  # now, how to calculate back 
	  # push @durations, $duration2;
	}
      }
    }
    ;
    my $entirelynewdatestring = join(" ",Compress(Minutes => $res->{minutes}),Compress(Hours => $res->{hours}),$idk1s,$idk2s,Compress(DOW => $res->{days}));
    # print Dumper({New => $entirelynewdatestring});
    return $entirelynewdatestring;
  }
}

sub Compress {
  my %args = @_;
  my $entry;
  my $max;
  if (exists $args{DOW}) {
    $entry = $args{DOW};
    $max = 7;
  } elsif (exists $args{Minutes}) {
    $entry = $args{Minutes};
    $max = 60;
  } elsif (exists $args{Hours}) {
    $entry = $args{Hours};
    $max = 24;
  }
  my @seg;
  my @segs;
  foreach my $item (0..$max) {
    if ($item != $max and exists $entry->{$item}) {
      push @seg, $item;
    } else {
      if (scalar @seg) {
	if (scalar @seg == 1) {
	  push @segs, $seg[0];
	} else {
	  push @segs, $seg[0]."-".$seg[$#seg];
	}
	@seg = ();
      }
    }
  }
  my $compressed = join(",",@segs);
  if ($compressed eq "0-".($max-1)) {
    return "*";
  } else {
    return $compressed;
  }
}

sub GetNumbers {
  my %args = @_;
  my $entry;
  my $max;
  if (exists $args{DOW}) {
    $entry = $args{DOW};
    $max = 7;
  } elsif (exists $args{Minutes}) {
    $entry = $args{Minutes};
    $max = 60;
  } elsif (exists $args{Hours}) {
    $entry = $args{Hours};
    $max = 24;
  }
  my @retval;
  foreach my $seg (split /\s*,\s*/,$entry) {
    if ($seg =~ /^(\d+)\s*-\s*(\d+)$/) {
      push @retval, $1..$2;
    } elsif ($seg eq "*") {
	push @retval, 0..($max-1);
    } else {
      push @retval, $seg;
    }
  }
  return @retval;
}

sub StartCron {
  my ($self,%args) = @_;
  print "Starting Schedule::Cron.\n";
  $self->PID
    ($self->MyCron->run
     (detach => 1));
}

sub StopCron {
  my ($self,%args) = @_;
  print "Stopping Schedule::Cron.\n";
  system "kill -9 ".$self->PID;
  $self->PID(undef);
}

sub Execute {
  my ($self,%args) = @_;
  # now we monitor
  while (1) {
    if (defined $self->LastLoadTime) {
      my $res = ExistsRecent
	(
	 File => $self->CronFile,
	 Within => time - $self->LastLoadTime,
	);
      if (defined $res->{Exists} and
	  $res->{Recent} == 1) {
	$self->StopCron;
      }
    }
    if (! defined $self->PID) {
      $self->LoadCronFile;
      $self->StartCron;
    }
    sleep 60;
  }
}

sub Dispatcher {
  my ($self,%args) = @_;
  my %args2 = %{$args{arguments}};
  # some things to add here, a larger goal, which is to have all current
  # goals of a certain category complete..., be able to edit with SPSE2?

  my $date = `date`;
  chomp $date;
  my $warningtime = $args2{WarningTime};
  my $c = "Agenda: <".$args2{Task}."> <".$args2{Desc}."> $date";
  my $res = $self->MyGoalEditor->CreateGoal
    (
     Description => $args2{Desc},
    );
  if ($res->{Success}) {
    foreach my $entryid (keys %{$res->{Result}}) {
      my $entryfn = $res->{Result}->{$entryid};
      $UNIVERSAL::agent->SendContents
      	(
      	 Receiver => "KBS2",
      	 Data => {
      		  Command => "assert",
      		  Context => $self->Context,
      		  Formula => ["due-date-for-entry", $entryfn, $warningtime],
		  Flags => {
			    AssertWithoutCheckingConsistency => 1,
			   },
      		 },
            	);
      $UNIVERSAL::agent->SendContents
	(
	 Receiver => "Notification-Manager",
	 Data => {
		  Action => "Add",
		  Type => "Notifications",
		  Description => $args2{Desc},
		  Context => $self->Context,
		  EntryFn => $entryfn,
		 },
	);
    }
  }
}

# sub Dispatcher {
#   my (%args) = @_;
#   my %args2 = %{$args{arguments}};
#   my $date = `date`;
#   chomp $date;
#   my $warningtime = $args2{WarningTime};
#   my $c = "Agenda: <".$args2{Task}."> <".$args2{Desc}."> $date";
#   print "$c\n";
#   my $quotedc = shell_quote($c);
#   $UNIVERSAL::agent->SendContents
#     (Contents => $c);
#   sleep 2;
#   my $entryid = `/var/lib/myfrdcsa/codebases/internal/freekbs/scripts/lookup-entry.pl unilang messages Contents ID $quotedc`;
#   chomp $entryid;
#   my $d = "KBS, MySQL:freekbs:default assert (\"due-date-for-entry\" \"$entryid\" \"$warningtime\")";
#   print "$d\n";
#   print "WTF!\n";
#   $UNIVERSAL::agent->SendContents
#     (Contents => $d);
#   # send something to the notification manager
#   print "WTF!\n";
# }

# add the ability to choose what type of alarm is played
# a one off alarm

# a continuous until responded to alarm

# system should know if sound is on, if headphones are plugged in, etc

# system should route alerts to phone and have them answerable via the
# Android-FRDCSA-Client

# look into dyndns.org for android phone

# http://l6n.org/android/market.php?destination=http://market.android.com/search?q=pname:org.l6n.dyndns

# http://code.google.com/p/android-xmlrpc/source/browse/branches/XMLRPC-r15/src/org/xmlrpc/android/XMLRPCServer.java?r=16

# afc-1.dyndns.org

# http://freshmeat.net/projects/android-scripting-environment

1;
