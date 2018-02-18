package Manager::Misc::Light2;

# BE THE MASTER OF YOURSELF
# basically, the system accomplishes,  in whatever ways necessary what
# is  intended to  be  performed by  the "domain.lisp"  file.

use Data::Dumper;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / Actions Debug Domainfile Events Task2Action Tasks /

  ];

sub init {
  my ($self,%args) = @_;
  $self->Events({});
  $self->Actions({});
  $self->Task2Action({});
  $self->Domainfile
    ($args{DomainFile});
  $self->Tasks({});
  $self->Debug(0);
}

sub Execute {
  my ($self,%args) = @_;
  $self->Light;
}

sub SaveDomain {
  my ($self) = @_;
  $self->SaveDataToFile(File => $self->Domainfile,
			Data => $domain);
}

sub LoadDomain {
  my ($self) = @_;
  $self->LoadDataFromFile(File => $self->Domainfile,
			  Data => $domain);
}

sub LoadDataFromFile {
  my ($self,%args) = @_;
  my $c = `cat "$args{File}"`;
  $args{Data} = eval $c;
}

sub PrintDomain {
  my ($self) = @_;
  print Dumper($domain);
}

sub ProcessInput {
  my ($self) = @_;

}

sub WalkThrough {
  my ($self) = @_;
  # program to walk through constraints
}

sub ShowCurrentDomain {
  my ($self) = @_;

}

sub ReportEvent {
  my ($self) = @_;

}

sub InOrderTraverseDomain {
  my ($self,@q) = @_;
  my @l = ();
  my @tasks = ();
  push @q, @$domain;
  while (@q) {
    my $x = shift @q;
    if (ref $x eq "ARRAY") {
      if ($x->[0] eq "task") {
	push @tasks, $x;
      }
      unshift @q, @$x;
    } else {
      push @l, $x;
    }
  }
  print Dumper([@tasks]);
}

sub ParseDomainFile {
  my ($self,%args) = @_;
  $self->Domainfile($args{DomainFile});
  $f = $self->Domainfile;
  my $c = `cat "$f"`;
  $self->Parse
    (Contents => $c);
}

sub Parse {
  my ($self,%args) = @_;
  my $c = $args{Contents};
  $c =~ s/;.*//mg;
  my $tokens = [split //,$c];
  my $cnt = 0;
  my $stack = [];
  my $symbol = "";
  my $state = "default";
  my $state2 = "default";
  do {
    $char = shift @$tokens;
    if ($state2 eq "becomebackslash") {
      $state2 = "backslash";
    }
    if ($char =~ /\(/) {
      if ($state eq "default") {
	++$cnt;
	$stack->[$cnt] = [];
	$symbol = "";
      } elsif ($state eq "in_quote" or $state eq "in_singlequote") {
	# just add it to the string
	# this is just something in a string, add as one normally would
	$symbol .= $char;
      }
    } elsif ($char =~ /[\s\n]/) {
      if ($state eq "default") {
	if (length $symbol) {
	  push @{$stack->[$cnt]},$symbol;
	  $symbol = "";
	}
      } elsif ($state eq "in_quote" or $state eq "in_singlequote") {
	$symbol .= $char;
      }
    } elsif ($char =~ /\\/) {
      if ($state eq "default") {
	$symbol .= $char;
	if ($state2 eq "default") {
	  print "ERROR: default state has backslash\n";
	} elsif ($state2 eq "backslash") {
	  print "ERROR: default state has (double) backslash\n";
	} else {
	  print "ERROR: default state has state2less backslash\n";
	}
      } elsif ($state eq "in_quote" or $state eq "in_singlequote") {
	$symbol .= $char;
	$state2 = "becomebackslash";
      }
    } elsif ($char =~ /"/) {
      # there are three cases: opening_quote, closing_quote, quote_in_singlequote
      # there are a few states: default, in_quote, in_singlequote
      if ($state eq "default") {
	# if there is a backslash, this is strange
	if ($state2 eq "default") {
	  # this is an opening_quote
	  $state = "in_quote";
	  if (length $symbol) {
	    push @{$stack->[$cnt]},$symbol;
	  }
	  $symbol = '"';
	} elsif ($state2 eq "backslash") {
	  $symbol .= $char;
	  print "ERROR: backslashed quote in default state\n";
	} else {
	  $symbol .= $char;
	  print "ERROR: quote with state2 undefined\n";
	}
      } elsif ($state eq "in_quote") {
	if ($state2 eq "default") {
	  # this means this is a closing_quote
	  $symbol .= '"';
	  if (length $symbol) {
	    push @{$stack->[$cnt]}, $symbol;
	    $symbol = "";
	  }
	  $state = "default";
	} elsif ($state2 eq "backslash") {
	  $symbol .= $char;
	} else {
	  return {
		  Success => 0,
		  Reasons => {
			      "quote with state = in_quote, state2 undefined" => 1,
			     }
		 };
	}
      } elsif ($state eq "in_singlequote") {
	# we just add it like anything else, even when backslashed???  '\"'  what does that yield?
	$symbol .= $char;
      }
    } elsif ($char =~ /'/) {
      # there are three cases: opening_singlequote, closing_singlequote, singlequote_in_quote
      # there are a few states: default, in_quote, in_singlequote
      if ($state eq "default") {
	if ($state2 eq "default") {
	  # this is an opening_quote
	  $state = "in_singlequote";
	  if (length $symbol) {
	    push @{$stack->[$cnt]}, $symbol;
	  }
	  $symbol = "'";
	} elsif ($state2 eq "backslash") {
	  $symbol .= $char;
	  print "ERROR: backslashed singlequote in default state\n";
	} else {
	  $symbol .= $char;
	  print "ERROR: singlequote in default state with state2 undefined\n";
	}
      } elsif ($state eq "in_quote") {
	# we just add it like anything else, even when backslashed???  '\"'  what does that yield?
	$symbol .= $char;
      } elsif ($state eq "in_singlequote") {
	if ($state2 eq "default") {
	  # this means this is a closing_singlequote
	  $symbol .= "'";
	  if (length $symbol) {
	    push @{$stack->[$cnt]}, $symbol;
	    $symbol = "";
	  }
	  $state = "default";
	} elsif ($state2 eq "backslash") {
	  $symbol .= $char;
	} else {
	  return {
		  Success => 0,
		  Reasons => {
			      "singlequote with state = in_singlequote, state2 undefined" => 1,
			     }
		 };
	}
      }
    } elsif ($char =~ /\)/) {
      if ($state eq "default") {
	# now $stack->[$cnt] holds all of  our objects, and so just have
	# to move those into the right place
	if (length $symbol) {
	  push @{$stack->[$cnt]},$symbol;
	  $symbol = "";
	}
	my @a = @{$stack->[$cnt]};
	$stack->[$cnt] = undef;
	--$cnt;
	push @{$stack->[$cnt]}, \@a;
      } elsif ($state eq "in_quote" or $state eq "in_singlequote") {
	$symbol .= $char;
      }
    } else {
      if ($char !~ /\s/) {
	$symbol .= $char;
      } else {
	print "ERROR: backslash-s character\n";
      }
    }
  } while (@$tokens);
  $domain = $stack->[0];
  return {
	  Success => 1,
	  Domain => $domain,
	 };
}

sub Generate {
  my ($self,%args) = @_;
  my $structure = $args{Structure};
  my @res = ();
  foreach my $x (@$structure) {
    if (ref $x eq "ARRAY") {
      push @res, $self->Generate(Structure => $x);
    } else {
      push @res, $x;
    }
  }
  return "(". join(" ",@res).")";
}

sub HasArray {
  my ($self,$s) = @_;
  my $ha = 0;
  foreach my $x (@$s) {
    if (ref $x eq "ARRAY") {
      $ha = 1;
    }
  }
  return $ha;
}

sub PrettyGenerate {
  my ($self,%args) = @_;
  my $structure = $args{Structure};
  my $indentation = "";
  my $retval;
  my $depth;
  if ((! defined $args{PrettyPrint}) or $args{PrettyPrint}) {
    $depth = defined $args{Indent} ? $args{Indent} : 0;
  } else {
    $depth = defined $args{Indent} ? ($args{Indent} > 0) : 0;
  }
  $indentation = (" " x $depth);
  $retval = "$indentation(";
  my $total = scalar @$structure;
  my $cnt = 0;
  if (ref($structure) eq 'ARRAY') {
    foreach my $x (@$structure) {
      ++$cnt;
      if (ref $x eq "ARRAY") {
	my $c = $self->PrettyGenerate
	  (
	   Structure => $x,
	   PrettyPrint => $args{PrettyPrint},
	   Indent => ($args{Indent} || 0) + 1,
	  );
	if ((! defined $args{PrettyPrint}) or $args{PrettyPrint}) {
	  $retval .= "\n";
	}
	$retval .= "$c";
      } else {
	$retval .= " " if $cnt > 1;
	$retval .= "$x";
      }
    }
    $retval .= ")";
    return $retval;
  } else {
    return $structure;
  }
}

sub ExportCurrentDomain {
  my ($self) = @_;

}

sub ExportCurrentWorldModel {
  my ($self) = @_;

}

sub LoadCurrentWorldModel {
  my ($self) = @_;

}

sub SaveCurrentWorldModel {
  my ($self) = @_;

}

sub DeclareTask {
  my ($self,%args) = @_;
  my $task = $args{Task};
  # check that its not a complex task
  my $complex = 0;
  foreach my $e (@$task) {
    if (ref $e eq "ARRAY") {
      $complex = 1;
    }
  }

  if (! $complex) {
    my @s = @$task;
    shift @s;
    my $action = $task->[1];
    if (! exists $self->Actions->{$action}) {
      print "Declaring action: $action\n" if $self->Debug;
      $self->Actions->{$action} = 1;
      $self->Task2Action->{$action} = {};
    }

    my $taskdescription = join(" ",@s);
    if (! exists $self->Tasks->{$taskdescription}) {
      print "Declaring task: $taskdescription\n" if $self->Debug;
      $self->Tasks->{$taskdescription} = $task;
      $self->Task2Action->{$task->[1]}->{$taskdescription} = 1;
    }
  } else {
    print "Declaring complex task: ".$task->[1]."\n" if $self->Debug;
  }
}

sub DeclareEvent {
  my ($self,%args) = @_;
  my $event = $args{Event};
  if (ref $event eq "ARRAY") {
    $name = $self->Generate(Structure => $event->[1]);
  } else {
    $name = $event->[1];
  }
  print "Declaring event: $name\n" if $self->Debug;
  $self->Events->{$name} = $event;
}

sub Clean {
  my ($self,$t) = @_;
  $t =~ s/\n//g;
  return $t;
}

sub Choose {
  my ($self,%args) = @_;
  if ($args{Options}) {
    if ($args{Message}) {
      print $args{Message}."\n";
    }
    my $i = 0;
    foreach my $o (@{$args{Options}}) {
      print $i++.") $o\n";
    }
    my $ret = "";
    while ($ret !~ /^([0-9]+|q)$/) {
      $ret = <STDIN>;
      $ret = $self->Clean($ret);
    }
    # print Dumper($args{Options}->[$ret]);
    return $args{Options}->[$ret];
  }
}

sub PrepareForEvent {
  my ($self,@o) = @_;
  return $self->Choose(Message => "Have any of these events occurred?",
		       Options => \@o);
}

sub PrintEvent {
  my ($self,$event) = @_;
  print $self->PrettyGenerate
    (
     Structure => $self->Events->{$event},
    )."\n";
}

sub PerformTaskList {
  my ($self,$event) = @_;
  print Dumper($event);
  # at this point want to walk through
  $self->PrintEvent($event);
}

sub Loop {
  my ($self) = @_;
  # have the user  select whether a given set  of events has occurred,
  # load the event processor
  while (1) {
    my $event = $self->PrepareForEvent();
    $self->PerformTaskList($event);
  }
}

sub EvalDomain {
  my ($self,%args) = @_;
  my $dm = $args{Domain};
  my @q = ();
  my @l = ();
  my @tasks = ();
  my @events = ();
  push @q, @$dm;
  while (@q) {
    my $x = shift @q;
    if (ref $x eq "ARRAY" and scalar @$x) {
      if ($x->[0] eq "task") {
	$self->DeclareTask(Task => $x);
	push @tasks, $x;
      }
      if ($x->[0] eq "event") {
	$self->DeclareEvent(Event => $x);
	push @events, $x;
      }
      unshift @q, @$x;
    } else {
      push @l, $x;
    }
  }
  # print Dumper([@tasks]);
}

sub Light {
  my ($self) = @_;
  $self->ParseDomainFile
    (DomainFile => $self->Domainfile);
  $self->EvalDomain
    (Domain => $domain);
  $self->Loop;
}

1;
