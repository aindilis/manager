package Manager::Dialog;

use Data::Dumper;
use Tk;
use Tk::Checkbutton;
use Tk::Dialog;

use Text::Wrap qw(wrap $columns);

use Try::Tiny;

require Exporter;
@ISA = qw(Exporter);

@EXPORT_OK = qw (QueryUser QueryUser2 ComplexQueryUser Verify Approve
		 Approve2 ApproveStrongly ApproveCommand
		 ApproveCommand2 Choose Choose2 ChooseSpecial
		 EasyQueryUser PrintList Message ApproveCommands
		 ChooseHybrid ChooseOrCreateNew SubsetSelect
		 FamilySelect ChooseByProcessor Continue);

# A disciplined approach to dialog management with the user.

if (exists $ENV{FRDCSA_DASHBOARD} and $ENV{FRDCSA_DASHBOARD} eq "enabled") {
  $UNIVERSAL::managerdialogtkwindow = MainWindow->new(-title => join(" ",$0, @ARGV));
}
my $continueloop;
my $cancel;
$columns = 80;

sub EasyQueryUser {
  if (exists $ENV{FRDCSA_DASHBOARD} and $ENV{FRDCSA_DASHBOARD} eq "enabled") {
    print "ERROR: Manager::Dialog needs to convert this function to use Tk\n";
  }
  my $entry;
  chomp ($entry = <STDIN>);
  return $entry;
}

sub QueryUser {
  my ($contents) = (shift || "");
  if (defined $UNIVERSAL::managerdialogtkwindow) {
    my $top1 = $UNIVERSAL::managerdialogtkwindow->Toplevel();
    my $searchtext = "";
    my $queryframe = $top1->Frame();
    my $label = $queryframe->Label(-text => $contents);
    $label->pack();
    my $query = $queryframe->Entry
      (
       -relief       => 'sunken',
       -borderwidth  => 2,
       -textvariable => \$searchtext,
       -width        => 70,
      )->pack(-side => 'left');
    $queryframe->Button
      (
       -text => "Submit",
       -command => sub {
	 $continueloop = 0;
       },
      )->pack(-side => 'right');
    $queryframe->Button
      (
       -text => "Cancel",
       -command => sub {
	 $continueloop = 0;
	 $cancel = 1;
       },
      )->pack(-side => 'right');
    $queryframe->pack;
    $query->bind
      (
       "all",
       "<Return>",
       sub {
	 $continueloop = 0;
       },
      );
    $query->focus;
    MyMainLoop();
    $top1->destroy();
    DoOneEvent(0);
    if (! $cancel) {
      return $searchtext;
    } else {
      return;
    }
  } else {
    my $tmp = shift;
    if ($tmp) {
      print $contents;
    } else {
      print "$contents\n> ";
    }
    my $result = <STDIN>;
    while ($result =~ /^$/) {
      $result = <STDIN>;
    }
    chomp $result;
    return $result;
  }
}

sub QueryUser2 {
  my (%args) = @_;
  if (defined $UNIVERSAL::managerdialogtkwindow) {
    my $top1 = $UNIVERSAL::managerdialogtkwindow->Toplevel
      (
       -title => $args{Title} || "Query User",
      );
    my $searchtext = $args{DefaultValue} || "";
    my $queryframe = $top1->Frame();
    my $label = $queryframe->Label(-text => $args{Message});
    $label->pack();
    my $query = $queryframe->Entry
      (
       -relief       => 'sunken',
       -borderwidth  => 2,
       -textvariable => \$searchtext,
       -width        => 70,
      )->pack(-side => 'left');
    $queryframe->Button
      (
       -text => "Submit",
       -command => sub {
	 $continueloop = 0;
       },
      )->pack(-side => 'right');
    $queryframe->Button
      (
       -text => "Cancel",
       -command => sub {
	 $continueloop = 0;
	 $cancel = 1;
       },
      )->pack(-side => 'right');
    $queryframe->pack;
    $query->bind
      (
       "all",
       "<Return>",
       sub {
	 $continueloop = 0;
       },
      );
    $top1->bind
      (
       "all",
       "<Escape>",
       sub {
	 $continueloop = 0;
	 $cancel = 1;
       },
      );
    $query->focus;
    MyMainLoop();
    $top1->destroy();
    DoOneEvent(0);
    return {
	    Cancel => $cancel,
	    Value => $searchtext,
	   };
  } else {
    $args{Message} ||= "";
    $args{Prompt} ||= ">";
    print $args{Message}."\n".$args{Prompt}." ";
    my $result = <STDIN>;
    while ($result =~ /^$/) {
      $result = <STDIN>;
    }
    chomp $result;
    return $result;
  }
}

sub ComplexQueryUser {
  my %args = @_;
  if (exists $ENV{FRDCSA_DASHBOARD} and $ENV{FRDCSA_DASHBOARD} eq "enabled") {
    print "ERROR: Manager::Dialog needs to convert this function to use Tk\n";
  }
  my $prompt = $args{Prompt} || "> ";
  my ($contents) = $args{Query}."\n" || "";
  print "$contents$prompt";
  my $result = <STDIN>;
  while ($result =~ /^$/) {
    $result = <STDIN>;
  }
  chomp $result;
  return $result;
}

sub Verify {
  my ($contents) = (shift || "Is this correct?");
  if (exists $ENV{FRDCSA_DASHBOARD} and $ENV{FRDCSA_DASHBOARD} eq "enabled") {
    print "ERROR: Manager::Dialog needs to convert this function to use Tk\n";
  }
  my $result = QueryUser($contents);
  while ($result !~ /^[yY|nN]$/) {
    $result = QueryUser("Please respond: [yYnN]");
  }
  return ($result =~ /^[yY]$/);
}

sub ApproveCommand {
  my $command = shift;
  if (exists $ENV{FRDCSA_DASHBOARD} and $ENV{FRDCSA_DASHBOARD} eq "enabled") {
    print "ERROR: Manager::Dialog needs to convert this function to use Tk\n";
  }
  print "$command\n";
  if (Approve("Execute this command? ")) {
    system $command;
    return 1;
  }
  return;
}

sub ApproveCommand2 {
  my %args = @_;
  my $command = $args{Command};
  if (exists $ENV{FRDCSA_DASHBOARD} and $ENV{FRDCSA_DASHBOARD} eq "enabled") {
    print "ERROR: Manager::Dialog needs to convert this function to use Tk\n";
  }
  print "$command\n";
  if ($args{AutoApprove} || Approve("Execute this command? ")) {
    system $command;
    return
      {
       Approved => 1,
       Retval => $?,
      };
  }
  return
    {
     Approved => 0,
    };
}

sub ApproveCommands {
  my %args = @_;
  if (defined $UNIVERSAL::managerdialogtkwindow) {
    if ((defined $args{Method}) && ($args{Method} =~ /parallel/i)) {
      my $dialog = $UNIVERSAL::managerdialogtkwindow->Dialog
	(
	 -text => "Execute these commands?\n\n".join("\n",@{$args{Commands}}),
	 -buttons => [qw/Yes No/],
	);
      if ($args{AutoApprove} || $dialog->Show() eq "Yes") {
	foreach my $command (@{$args{Commands}}) {
	  print $command."\n";
	  system $command if ! $args{Simulate};
	}
	return 1;
      } else {
	return 0;
      }
    } else {
      my $outcome = 0;
      foreach $command (@{$args{Commands}}) {
	my $dialog = $UNIVERSAL::managerdialogtkwindow->Dialog
	  (
	   -text => "Execute this command?\n\n".$command,
	   -buttons => [qw/Yes No/],
	  );
	if ($args{AutoApprove}) {
	  print $command."\n";
	  system $command;
	  ++$outcome;
	} elsif ($dialog->Show eq "Yes") {
	  print $command."\n";
	  system $command;
	  ++$outcome;
	}
      }
      return $outcome;
    }
  } else {
    if ((defined $args{Method}) && ($args{Method} =~ /parallel/i)) {
      foreach $command (@{$args{Commands}}) {
	Message(Message => $command);
      }
      # bug: use proof theoretic fail conditions here instead
      if ($args{AutoApprove} || Approve("Execute these commands?")) {
	foreach my $command (@{$args{Commands}}) {
	  system $command if ! $args{Simulate};
	}
	return 1;
      } else {
	return 0;
      }
    } else {
      my $outcome = 0;
      foreach $command (@{$args{Commands}}) {
	my $res = ApproveCommand2
	  (
	   Command => $command,
	   AutoApprove => $args{AutoApprove},
	  );
	print Dumper({Res => $res}) if 0;
	if ($args{CheckReturnValues}) {
	  if ($res->{Retval}) {
	    my $res2 = {
		    Success => 0,
		    Approved => $res->{Approved},
		    Retval => $res->{Retval},
		    Outcome => $outcome,
		   };
	    print Dumper({Res2 => $res2}) if 0;
	    return $res2;
	  } else {
	    ++$outcome;
	  }
	} else {
	  ++$outcome;
	}
      }
      if ($args{CheckReturnValues}) {
	return {
		Success => $res->{Approved},
		Approved => $res->{Approved},
	       };
      } else {
	return $outcome;
      }
    }
  }
}

sub Approve2 {
  my (%args) = @_;
  if ($args{AutoApprove}) {
    print "Autoapproved: <".$args{Message}.">\n";
    return 1;
  } else {
    return Approve($args{Message});
  }
}

sub Approve {
  if (defined $UNIVERSAL::managerdialogtkwindow) {
    my $dialog = $UNIVERSAL::managerdialogtkwindow->DialogBox
      (
       -title => shift || "Is this correct?",
       -buttons => [qw/Yes No/],
      );
    my $res = $dialog->Show();
    if ($res eq "Yes") {
      return 1;
    }
    return 0;
  } else {
    my $message = shift || "Is this correct? ([yY]|[nN])\n";
    $message =~ s/((\?)?)[\s]*$/$1: /;
    print $message;
    my $antwort = <STDIN>;
    chomp $antwort;
    if ($antwort =~ /^[yY]([eE][sS])?$/) {
      return 1;
    }
    return 0;
  }
}

sub ApproveStrongly {
  my $message = shift || "Is this correct? (yes|no)\n";
  if (exists $ENV{FRDCSA_DASHBOARD} and $ENV{FRDCSA_DASHBOARD} eq "enabled") {
    print "ERROR: Manager::Dialog needs to convert this function to use Tk\n";
  }
  $message =~ s/((\?)?)[\s]*$/$1: /;
  print "$message\n";
  my $antwort = <STDIN>;
  chomp $antwort;
  if ($antwort =~ /^(yes|no)$/i) {
    return 1;
  }
  return 0;
}

sub Choose {
  my @list = @_;
  if (defined $UNIVERSAL::managerdialogtkwindow) {
    if (0) {
      my $dialog = $UNIVERSAL::managerdialogtkwindow->Dialog
	(
	 -width => 500,
	 -height => 300,
	 -text => "Please Choose",
	 -buttons => \@list,
	);
      return $dialog->Show;
    } else {
      if (!@list) {
	return;
      } elsif (@list == 1) {
	print "<Chose:".$list[0].">\n";
	return $list[0];
      } else {
	my $top1 = $UNIVERSAL::managerdialogtkwindow->Toplevel
	  (
	   -title => "Please Choose",
	   -width => 800,
	   -height => 600,
	  );
	my $topframe = $top1->Frame();
	my $ourresults = ["WTF"];
	my @availableargs =
	  (
	   "Desc",
	   "MenuOffset",
	   "NoAllowWrap",
	   "Processor",
	   "Prompt",
	   "Selection",
	   "Set",
	   "Type",
	  );
	my $selectionframe = $topframe->Scrolled
	  ('Frame',
	   -scrollbars => 'e',
	  )->pack
	    (
	     -expand => 1,
	     -fill => "both",
	    );
	foreach my $item (@list) {
	  my $button = $selectionframe->Button
	    (
	     -text => $item,
	     -command => sub {
	       $continueloop = 0;
	       print "$item\n";
	       $ourresults = [$item];
	     },
	    );
	  $button->pack
	    (
	     -side => "top",
	     -expand => 1,
	     -fill => "both",
	    );
	}
	$selectionframe->pack
	  (
	   -side => "top",
	   -expand => 1,
	   -fill => "both",
	  );
	$topframe->pack
	  (
	   -fill => "both",
	   -expand => 1,
	  );
	MyMainLoop();
	$top1->destroy();
	DoOneEvent(0);
	return $ourresults->[0];
      }
    }
  } else {
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
      return $list[$response];
    }
  }
}

sub Choose2 {
  my %args = @_;
  my @list = @{$args{List}};
  my $wraps = {};
  my $title = $args{Title} || "Please Choose";
  if (defined $UNIVERSAL::managerdialogtkwindow) {
    if (!@list) {
      return;
    } elsif (@list == 1) {
      print "<Chose:".$list[0].">\n";
      return $list[0];
    } else {
      my $top1 = $UNIVERSAL::managerdialogtkwindow->Toplevel
	(
	 -width => 800,
	 -height => 600,
	 -title => $title,
	);
      my $topframe = $top1->Frame();
      my $ourresults = ["WTF"];
      my @availableargs =
	(
	 "Desc",
	 "MenuOffset",
	 "NoAllowWrap",
	 "Processor",
	 "Prompt",
	 "Selection",
	 "Set",
	 "Type",
	);

      my $selectionframe = $topframe->Scrolled
	('Frame',
	 -scrollbars => 'e',
	)->pack
	  (
	   -expand => 1,
	   -fill => "both",
	  );
      # add a cancel if $args{Cancel}
      if ($args{Cancel}) {
	unshift @list, "Cancel";
      }
      foreach my $item (@list) {
	# wrap the item if $args{Wrap}
	if ($args{Wrap}) {
	  my $wrap = wrap("","",$item);
	  $wraps->{$wrap} = $item;
	  $item = $wrap;
	}
	my $button = $selectionframe->Button
	  (
	   -text => $item,
	   -command => sub {
	     $continueloop = 0;
	     print "$item\n";
	     $ourresults = [$item];
	   },
	  );
	$button->pack
	  (
	   -side => "top",
	   -expand => 1,
	   -fill => "both",
	  );
      }
      $selectionframe->pack
	(
	 -side => "top",
	 -expand => 1,
	 -fill => "both",
	);
      $topframe->pack
	(
	 -fill => "both",
	 -expand => 1,
	);
      $top1->bind("<Button-4>", sub {$selectionframe->yview("scroll",-3,"units") });
      $top1->bind("<Button-5>", sub {$selectionframe->yview("scroll",3,"units") });
      $top1->geometry('640x480');
      MyMainLoop();
      $top1->destroy();
      DoOneEvent(0);
      my $res = $ourresults->[0];
      if ($args{Cancel} and $res eq "Cancel") {
	return;
      } elsif ($args{Wrap}) {
	return $wraps->{$res};
      } else {
	return $res;
      }
    }
  } else {
    my $i = 0;
    print $title."\n";
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
      return $list[$response];
    }
  }
}

sub ChooseSpecial {
  my %args = @_;
  if (exists $ENV{FRDCSA_DASHBOARD} and $ENV{FRDCSA_DASHBOARD} eq "enabled") {
    print "ERROR: Manager::Dialog needs to convert this function to use Tk\n";
  }
  my @list = @{$args{List}};
  if (!@list) {
    return;
  } elsif (@list == 1) {
    print "<Chose:".$list[0].">\n";
    return $list[0];
  } else {
    print PrintList(List => \@list,
		    Format => $args{Format});
    my $response;
    while (defined ($response = <STDIN>) and ($response !~ /^\d+$/)) {
    }
    chomp $response;
    return $list[$response];
  }
}

sub ChooseHybrid {
  my %args = @_;
  if (exists $ENV{FRDCSA_DASHBOARD} and $ENV{FRDCSA_DASHBOARD} eq "enabled") {
    print "ERROR: Manager::Dialog needs to convert this function to use Tk\n";
  }
  my @list = @{$args{List}};
  if (!@list) {
    return;
  } else {
    print PrintList(List => \@list,
		    Format => $args{Format});
    my $response;
    while (defined ($response = <STDIN>) and ($response =~ /^$/)) {
    }
    chomp $response;
    if ($response =~ /^\d+$/) {
      return ($list[$response],"match");
    } else {
      return ($response,"new");
    }
  }
}

sub ChooseReadkey {
  if (exists $ENV{FRDCSA_DASHBOARD} and $ENV{FRDCSA_DASHBOARD} eq "enabled") {
    print "ERROR: Manager::Dialog needs to convert this function to use Tk\n";
  }
  use Term::ReadKey;
  ReadMode('cbreak');
  if (defined ($char = ReadKey(-1)) ) {
    return $char;
  }
  ReadMode('normal');
}

sub PrintList {
  my %args = @_;
  if (exists $ENV{FRDCSA_DASHBOARD} and $ENV{FRDCSA_DASHBOARD} eq "enabled") {
    print "ERROR: Manager::Dialog needs to convert this function to use Tk\n";
  }
  my @list = @{$args{List}};
  my $format = $args{Format};
  my $result = "";
  my $i = 0;
  foreach my $item (@list) {
    if ($format eq "multiple") {
      $result .= "$i) $item\n";
    } elsif ($format eq "single") {
      $result .= "<$i:$item> ";
    } elsif ($format eq "simple") {
      $result .= "$item ";
    }
    ++$i;
  }
  return $result;
}

sub Message {
  my %args = @_;
  if (defined $UNIVERSAL::managerdialogtkwindow and $args{GetSignalFromUserToProceed}) {
    # print "ERROR: Manager::Dialog needs to convert this function to use Tk\n";
    my $dialog = $UNIVERSAL::managerdialogtkwindow->Dialog
      (
       -text => $args{Message},
       -buttons => [qw/Ok/],
      );
    my $res = $dialog->Show;
  } else {
    chomp $args{Message};
    print $args{Message}."\n";
  }
}

sub ChooseOrCreateNew {
  my %args = @_;
  if (exists $ENV{FRDCSA_DASHBOARD} and $ENV{FRDCSA_DASHBOARD} eq "enabled") {
    print "ERROR: Manager::Dialog needs to convert this function to use Tk\n";
  }
  my @list = @{$args{List}};
  unshift @list, "<Other>";
  unshift @list, "<Cancel>";
  my $result = Choose(@list);
  if ($result =~ /^<Cancel>$/) {
    return;
  } elsif ($result =~ /^<Other>$/) {
    return QueryUser("Please enter your choice");
  } else {
    return $result;
  }
}

sub PrintSelect {
  my (%args) = (@_);
  if (exists $ENV{FRDCSA_DASHBOARD} and $ENV{FRDCSA_DASHBOARD} eq "enabled") {
    print "ERROR: Manager::Dialog needs to convert this function to use Tk\n";
  }
  my @options = @{$args{Options}};
  my $selection = $args{Selection};
  my $i = $args{MenuOffset};
  my $nowrap = $args{NoAllowWrap};
  if ($nowrap) {
    foreach my $i (0..$#options) {
      my $option = $options[$i];
      chomp $option;
      if (defined $selection->{$i}) {
	print "* ";
      } else {
	print "  ";
      }
      print "$i) ".$option.
	(($args{Desc} and exists $args{Desc}->{$option}) ? "\t".$args{Desc}->{$option} : "")."\n";
      # print "$i) ".$option. "\n";
      $i = $i + 1;
    }
  } else {
    # figure out our viewport and use that, normally it is 180x67
    my $items = scalar @options;
    print Dumper({
		  Items => $items,
		  Options => \@options,
		 });
    my ($width, $height) = (100,15 * (int($items / 60) + 1));
    # figure out how many wraps we have to do

    my $rows = int($items / $height) + 1;
    my $rowwidth = $width / $rows;
    my $margin = $rowwidth - 1;
    my $j = 0;
    my $k = 0;
    my $line = {};

    foreach my $i (0..$#options) {
      my $option = $options[$i];
      chomp $option;
      $line->{$j}->{$k} = "";
      if (defined $selection->{$i}) {
	$line->{$j}->{$k} .= "* ";
      } else {
	$line->{$j}->{$k} .= "  ";
      }
      $line->{$j}->{$k} .= "$i) ".$option.
	(($args{Desc} and exists $args{Desc}->{$option}) ? "\t".$args{Desc}->{$option} : "");
      # print "$i) ".$option. "\n";
      $i = $i + 1;
      ++$j;
      if ($j >= $height) {
	$j = 0;
	++$k;
      }
    }
    foreach my $j (sort {$a <=> $b} keys %{$line}) {
      my @items;
      foreach my $k (sort {$a <=> $b}  keys %{$line->{$j}}) {
	my @item = ($line->{$j}->{$k});
	push @items, substr(eval "sprintf(\"\%-${margin}s\",\@item)",0,$margin);
      }
      print join(" ",@items)."\n";
    }
  }
}

sub SubsetSelect {
  my (%args) = (@_);
  if (defined $UNIVERSAL::managerdialogtkwindow) {
    my $title = $args{Title} || undef;
    my $top1 = $UNIVERSAL::managerdialogtkwindow->Toplevel
      (
       -title => $title,
      );
    my $topframe = $top1->Frame();
    if ($args{Message}) {
      my $text = $topframe->Text
	(
	 -width => 80,
	 -height => 10,
	);
      $text->Contents($args{Message});
      $text->configure(-state => "disabled");
      $text->pack();
    }
    my $ourresults;
    my @availableargs =
      (
       "Desc",
       "MenuOffset",
       "NoAllowWrap",
       "Processor",
       "Prompt",
       "Selection",
       "Set",
       "Type",
      );

    my $selectionframe = $topframe->Scrolled
      ('Frame',
       -scrollbars => 'e',
      )->pack
	(
	 -expand => 1,
	 -fill => "both",
	);
    foreach my $item (@{$args{Set}}) {
      my $button = $selectionframe->Checkbutton
	(
	 -text => $item,
	);
      $button->pack(-side => "top", -expand => 1, -fill => "both");
      if (exists $args{Selection}->{$item}) {
	$button->{Value} = 1;
      }
    }
    $selectionframe->pack(-side => "top", -expand => 1, -fill => "both");

    my $buttonframe = $topframe->Frame;
    $buttonframe->Button
      (
       -text => "Select",
       -command => sub {
	 my @results;
	 foreach my $child ($selectionframe->{SubWidget}->{scrolled}->{SubWidget}->{frame}->children) {
	   if (defined $child->{'Value'} and $child->{'Value'}) {
	     push @results, $child->cget('-text');
	   }
	 }
	 $continueloop = 0;
	 $ourresults = \@results;
       },
      )->pack(-side => "right");
    $buttonframe->Button
      (
       -text => "Cancel",
       -command => sub { $top1->destroy(); },
      )->pack(-side => "right");
    $buttonframe->pack(-side => "bottom");
    $topframe->pack(-fill => "both", -expand => 1);

    MyMainLoop();
    $top1->destroy();
    DoOneEvent(0);
    return @$ourresults;
  } else {
    my @options;
    my $map = {};
    if ($args{Processor}) {
      @options = map &{$args{Processor}},@{$args{Set}};
    } else {
      @options = @{$args{Set}};
    }
    my $type = $args{Type};
    my $prompt = $args{Prompt} || "> ";
    if (scalar @options > 0) {
      unshift @options, "Finished";
      my %selection = ();
      if ($args{Selection}) {
	%tmp = %{$args{Selection}};
	foreach my $i (1..($#options)) {
	  print Dumper({
			I => $i,
			Tmp => \%tmp,
			Test => \@options,
		       }) if 0;
	  if (exists $tmp{$options[$i]}) {
	    $selection{$i} = 1;
	  }
	}
      }
      while (1) {
	PrintSelect
	  (Options => \@options,
	   Selection => \%selection,
	   MenuOffset => $args{MenuOffset} || 0,
	   NoAllowWrap => $args{NoAllowWrap},
	   Desc => $args{Desc});
	print $prompt;
	my $ans = <STDIN>;
	my $query;
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
	      } elsif ($a =~ /^o(.*)/) {
		%selection = ();
		$a = $1;
		$method = "select-only";
	      } elsif ($a =~ /^q(.*)/) {
		$query = $1;
		$method = "search";
		$a = "0-".$#options;
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
		  if (defined $selection{$i}) {
		    delete $selection{$i};
		  } else {
		    $selection{$i} = 1;
		  }
		} elsif ($method eq "deselect") {
		  if (defined $selection{$i}) {
		    delete $selection{$i};
		  }
		} elsif ($method eq "select" or $method eq "select-only") {
		  $selection{$i} = 1;
		} elsif ($method eq "search") {
		  if ($options[$i] =~ /$query/) {
		    if (defined $selection{$i}) {
		      delete $selection{$i};
		    } else {
		      $selection{$i} = 1;
		    }
		  }
		}
	      }
	    }
	  } else {
	    if (defined $type and $type eq "int") {
	      my @retvals;
	      my $i = $args{MenuOffset} || 0;
	      foreach my $i (0..$#options) {
		if ($selection{$i}) {
		  push @retvals, $i - 1;
		}
		++$i;
	      }
	      return @retvals;
	    } else {
	      my @retvals;
	      my $i = $args{MenuOffset} || 0;
	      foreach my $i (0..$#options) {
		if ($selection{$i}) {
		  push @retvals, $args{Set}->[$i - 1];
		  # print Dumper($args{Set}->[$i - 1]);
		}
		++$i;
	      }
	      return @retvals;
	    }
	  }
	}
      }
    } else {
      return;
    }
  }
}

sub FamilySelect {
  my (%args) = (@_);
  if (exists $ENV{FRDCSA_DASHBOARD} and $ENV{FRDCSA_DASHBOARD} eq "enabled") {
    print "ERROR: Manager::Dialog needs to convert this function to use Tk\n";
  }
  # let's just do any easy one
  print "Family Select\n";
  print Dumper($args{Selection});
  my @subsets;
  do {
    push @subsets,
      [
       SubsetSelect
       (
	Set => $args{Set},
	Selection => $args{Selection},
	NoAllowWrap => $args{NoAllowWrap},
       )
      ];
  } while (! Approve("Finished Selecting Subsets? "));
  return @subsets;
}

# should write sublist select?

sub ChooseByProcessor {
  my (%args) = @_;
  if (exists $ENV{FRDCSA_DASHBOARD} and $ENV{FRDCSA_DASHBOARD} eq "enabled") {
    print "ERROR: Manager::Dialog needs to convert this function to use Tk\n";
  }
  my @entries = ();
  unless ($args{SkipCancel}) {
    @entries = ("_Cancel");
  }
  push @entries, map &{$args{Processor}}, @{$args{Values}};
  my $entry = Choose2
    (
     Title => $args{Title},
     List => \@entries,
    );
  my @matches;
  foreach my $v (@{$args{Values}}) {
    my @t = map &{$args{Processor}},($v);
    if ($t[0] eq $entry) {
      # if ($args{Processor}->($v) eq $entry) {
      push @matches, $v;
    }
  }
  return \@matches;
}

sub Continue {
  my (%args) = @_;
  if (exists $ENV{FRDCSA_DASHBOARD} and $ENV{FRDCSA_DASHBOARD} eq "enabled") {
    print "ERROR: Manager::Dialog needs to convert this function to use Tk\n";
  }
  if (! Approve("Continue?")) {
    &{$args{Result}};
  }
}

sub MyMainLoop
{
 unless ($inMainLoop)
  {
   local $inMainLoop = 1;
   $cancel = 0;
   $continueloop = 1;
   while ($continueloop)
    {
     DoOneEvent(0);
    }
  }
}

1;
