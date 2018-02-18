package Manager::Dialog::Record;

use PerlLib::MySQL;

use Data::Dumper;

require Exporter;
@ISA = qw(Exporter);
@EXPORT_OK = qw (Approve ApproveCommand ApproveCommands Choose
                 Message QueryUser SubsetSelect);

# A disciplined approach to dialog management with the user.

# some thoughts, by switching over to all hashes format, also add all
# special options found in original program

# also integrate Diamond Dialog

# do we need to record nos?  I think so, I think so...

sub Approve {
  my %args = @_;
  my $message = $args{Contents} ||"Is this correct? ([yY]|[nN])\n";
  $message =~ s/((\?)?)[\s]*$/$1: /;
  print $message;
  my $antwort = <STDIN>;
  chomp $antwort;
  if ($antwort =~ /^[yY]([eE][sS])?$/) {
    return 1;
    if ($args{Record}) {
      RecordItem
	(Record => $args{Record},
	 Structure =>
	 {
	  Type => "Approve",
	  Contents => \@{$args{Commands}},
	  Result => \@results,
	 });
    }
  }
  return 0;
}

sub ApproveCommand {
  my %args = @_;
  my $command = $args{Command} || "";
  print "$command\n";
  if (Approve
      (Contents => "Execute this command? ")) {
    # find some way to both print and get the result here
    system $command;
    $result = "";
    if ($args{Record}) {
      RecordItem
	(Record => $args{Record},
	 Structure =>
	 {
	  Type => "ApproveCommand",
	  Contents => $command,
	  Result => $result,
	 });
    }
    return 1;
  }
  return;
}

sub ApproveCommands {
  my %args = @_;
  if ((defined $args{Method}) && ($args{Method} =~ /parallel/i)) {
    foreach $command (@{$args{Commands}}) {
      Message(Message => $command);
    }
    # bug: use proof theoretic fail conditions here instead
    if (Approve(Contents => "Execute these commands? ")) {
      foreach my $command (@{$args{Commands}}) {
	system $command;
      }
      my @results;
      if ($args{Record}) {
	RecordItem
	  (Record => $args{Record},
	   Structure =>
	   {
	    Type => "ApproveCommands",
	    Contents => \@{$args{Commands}},
	    Result => \@results,
	   });
      }
      return 1;
    } else {
      return 0;
    }
  } else {
    my $outcome = 0;
    foreach $command (@{$args{Commands}}) {
      if (ApproveCommand
	  (
	   Command => $command,
	   Record => $args{Record},
	  )) {
	++$outcome;
      }
    }
    return $outcome;
  }
}

sub Choose {
  my %args = @_;
  my @list = @{$args{List}};
  my $i = 0;
  if (!@list) {
    return;
  } elsif (@list == 1) {
    print "<Chose:".$list[0].">\n";
    return $list[0];
  } else {
    foreach my $item (@list) {
      print "$i) $item\n";
      ++$i;
    }
    my $response;
    while (defined ($response = <STDIN>) and ($response !~ /^\d+$/)) {
    }
    chomp $response;
    my $result = $list[$response];
    if ($args{Record}) {
      RecordItem
	(Record => $args{Record},
	 Structure =>
	 {
	  Type => "Choose",
	  Contents => \@list,
	  Result => $result,
	 });
    }
    return $result;
  }
}

sub Message {
  my %args = @_;
  chomp $args{Message};
  print $args{Message}."\n";
  if ($args{Record}) {
    RecordItem
      (Record => $args{Record},
       Structure =>
       {
	Type => "Message",
	Contents => $args{Message},
       });
  }
}

sub QueryUser {
  my %args = @_;
  my $contents = $args{Contents} || "";
  print "$contents\n> ";
  my $result = <STDIN>;
  while ($result =~ /^$/) {
    $result = <STDIN>;
  }
  chomp $result;
  if ($args{Record}) {
    RecordItem
      (Record => $args{Record},
       Structure =>
       {
	Type => "QueryUser",
	Contents => $contents,
	Result => $result,
       });
  }
  return $result;
}

sub SubsetSelect {
  my %args = @_;
  my @options = @{$args{Set}};
  my %selection = ();
  if ($args{Selection}) {
    %selection = %{$args{Selection}};
  }
  my $type = $args{Type};
  my $prompt = $args{Prompt} || "> ";
  unshift @options, "Finished";
  if (scalar @options > 0) {
    while (1) {
      my $i = $args{MenuOffset} || 0;
      foreach my $option (@options) {
	chomp $option;
	if (defined $selection{$options[$i]}) {
	  print "* ";
	} else {
	  print "  ";
	}
	print "$i) ".$option.
	  (($args{Desc} and exists $args{Desc}->{$option}) ? "\t".$args{Desc}->{$option} : "")."\n";
	# print "$i) ".$option. "\n";
	$i = $i + 1;
      }
      print $prompt;
      my $ans = <STDIN>;
      chomp $ans;
      if ($ans ne "") {
	if ($ans) {
	  # go ahead and parse the language
	  foreach my $a (split /\s*,\s*/, $ans) {
	    my $method = "toggle";
	    if ($a =~ /^s(.*)/) {
	      $a = $1;
	      $method = "select";
	    } elsif ($a =~ /^d(.*)/) {
	      $a = $1;
	      $method = "deselect";
	    }
	    my $start = $a;
	    my $end = $a;
	    if ($a =~ /^\s*(\d+)\s*-\s*(\d+)\s*$/) {
	      $start = $1;
	      $end = $2;
	    }
	    for (my $i = $start; $i <= $end; ++$i) {
	      print "($i)\n";
	      if ($method eq "toggle") {
		if (defined $selection{$options[$i]}) {
		  delete $selection{$options[$i]};
		} else {
		  $selection{$options[$i]} = 1;
		}
	      } elsif ($method eq "deselect") {
		if (defined $selection{$options[$i]}) {
		  delete $selection{$options[$i]};
		}
	      } elsif ($method eq "select") {
		$selection{$options[$i]} = 1;
	      }
	    }
	  }
	} else {
	  if (defined $type and $type eq "int") {
	    my @retvals;
	    my $i = $args{MenuOffset} || 0;
	    foreach my $option (@options) {
	      if ($selection{$option}) {
		push @retvals, $i - 1;
	      }
	      ++$i;
	    }
	    if ($args{Record}) {
	      RecordItem
		(Record => $args{Record},
		 Structure =>
		 {
		  Type => "SubsetSelect",
		  Contents => \@options,
		  Result => \@retvals,
		 });
	    }
	    return @retvals;
	  } else {
	    if ($args{Record}) {
	      RecordItem
		(Record => $args{Record},
		 Structure =>
		 {
		  Type => "SubsetSelect",
		  Contents => \@options,
		  Result => [keys %selection],
		 });
	    }
	    return keys %selection;
	  }
	}
      }
    }
  } else {
    return;
  }
}

sub RecordItem {
  my (%args) = @_;
  if (0 and ! $Manager::Dialog::mysql) {
    $Manager::Dialog::mysql = PerlLib::MySQL->new
      (DBName => "manager-dialog");
    $Manager::Dialog::mysql->Insert
      (Table => "sessions",
       Values => [NULL,$0]);
    # maybe add datetime, for start and end
    $Manager::Dialog::session = $Manager::Dialog::mysql->InsertID;
  }
  if (0) {
    $Manager::Dialog::mysql->Insert
      (Table => "events",
       Values => [NULL,$Manager::Dialog::session,Dumper(%args)]);
  } else {
    print Dumper(%args);
  }
}

1;
