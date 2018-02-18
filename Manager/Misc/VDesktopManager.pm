package Manager::Misc::VDesktopManager;

use Manager::Dialog qw(Approve ApproveCommands QueryUser);

# get the CPM stuff, borrow setanta CPM stuff for now

use Data::Dumper;
use IO::File;
use String::ShellQuote;
use X11::WMCtrl;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / Simulate LocalHostname Style Width Height /

  ];

sub init {
  my ($self,%args) = @_;
  $self->Simulate($args{Simulate});
  $self->LocalHostname($args{LocalHostname} || $self->GetLocalHostname);
  $self->Style($args{Style});
  $self->Width($args{Width});
  $self->Height($args{Height});
}

sub LoadDefaults {
  my ($self,%args) = @_;
  if (! (defined $self->Style and defined $self->Width and defined $self->Height)) {
    $self->SetStyleWidthAndHeight;
  }
  my $style = $self->Style;
  if (Approve("Load Terminals")) {
    ApproveCommands
      (
       Commands => [
		    "killall -9 xterm", # honestly, find a nicer way to terminates these .....  setanta-agent???
		   ],
       Method => "parallel",
       Simulate => $self->Simulate,
      );

    if (0) {	    # made obsolete since passwords are all different now
      # now get the password and add it to the clipboard
      my $fh = IO::File->new;
      $fh->open("| xclip -i") or die "Cannot write password to clipboard\n";
      print $fh QueryUser("Password?")."\n";
      $fh->close;
    }

    my $widthheight = "--width ".$self->Width." --height ".$self->Height;
    my $preferences = {
		       "any" =>
		       [
			"manager-launch -t aloysius.frdcsa.org -s user --maximized --vdesktop 1,0 --wmtype $style $widthheight",
			"manager-launch -t posi.frdcsa.org -s user --maximized --vdesktop 2,0 --wmtype $style $widthheight",
			# "manager-launch -t ai.frdcsa.org -s user --maximized --vdesktop 3,0 --wmtype $style $widthheight",
			"manager-launch -t justin.frdcsa.org -s user --maximized --vdesktop 4,0 --wmtype $style $widthheight",
			"manager-launch -t game.frdcsa.org -s user --maximized --vdesktop 5,0 --wmtype $style $widthheight",

			"manager-launch -t aloysius.frdcsa.org -s root --maximized --vdesktop 1,1 --wmtype $style $widthheight",
			"manager-launch -t posi.frdcsa.org -s root --maximized --vdesktop 2,1 --wmtype $style $widthheight",
			# "manager-launch -t ai.frdcsa.org -s root --maximized --vdesktop 3,1 --wmtype $style $widthheight",
			"manager-launch -t justin.frdcsa.org -s root --maximized --vdesktop 4,1 --wmtype $style $widthheight",
			"manager-launch -t game.frdcsa.org -s root --maximized --vdesktop 5,1 --wmtype $style $widthheight",

			# "manager-launch -t ai.frdcsa.org -s cpm-user --vdesktop 0,1 --wmtype $style $widthheight",
			# "manager-launch -t ai.frdcsa.org -s cpm-work --vdesktop 0,1 --wmtype $style $widthheight",
		       ],

		       "ai.frdcsa.org" =>
		       [
			"manager-launch -t ai.frdcsa.org -s gnus --vdesktop 5,1 --wmtype $style $widthheight",
			"manager-launch -t ai.frdcsa.org -s irc1 --vdesktop 5,2 --wmtype $style $widthheight",
			"manager-launch -t ai.frdcsa.org -s irc2 --vdesktop 5,3 --wmtype $style $widthheight",
			# "manager-launch -t posiconsultancy.com -c /home/andrewdo/bin/virtualbox --vdesktop 3,2 --wmtype $style $widthheight",
		       ],

		       "columcille.frdcsa.org" =>
		       [
			# "manager-launch -t columcille.frdcsa.org -c /home/andrewdo/bin/virtualbox --vdesktop 3,2 --wmtype $style $widthheight",
		       ],
		      };

    my $localhostname = `hostname -f`;
    chomp $localhostname;
    my @tostart = ("any",$localhostname);
    foreach my $pref (@tostart) {
      my $sleep = $args{Speed} ? ($args{Speed} + 2) : 7;
      foreach my $command (@{$preferences->{$pref}}) {
	ApproveCommands
	  (
	   Commands => ["($command \&)"],
	   Method => "parallel",
	   AutoApprove => 1,
	   Simulate => $self->Simulate,
	  );
	sleep $sleep;
	$sleep = $args{Speed} ? $args{Speed} : 5;
      }
    }
  }

  if (Approve("Load Browser Tabs")) {
    my $browser = "firefox";
    my $browserexecutable = "firefox-bin";
    ApproveCommands
      (
       Commands => [
		    "killall -9 $browserexecutable", # honestly, find a nicer way to terminates these .....  setanta-agent???
		   ],
       Method => "parallel",
      );
    my $profiles =
      {
       Ionzero => {
		    VDesktop => [0,0],
		    Links => [
			      "http://mail.ionzero.com",
			      "https://www.google.com/calendar/render?tab=mc&pli=1",
			      "http://projects.ionzero.com",
			      "http://wiki.ionzero.com",
			     ],
		  },
       Projects => {
		    VDesktop => [0,1],
		    Links => [
			      "http://frdcsa.org",
			      "http://posi.frdcsa.org",
			      "http://rt.frdcsa.org/rt",
			     ],
		   },
       Personal => {
		    Links => [
			      "http://mail.google.com",
			      "http://voice.google.com",
			      "http://calendar.google.com",
			      "http://mail.yahoo.com",
			      "http://www.facebook.com",
			      "http://www.meetup.com",
			      "http://www.plentyoffish.com",
			      "http://twitter.com",
			      "http://identi.ca",
			      "http://aindilis.livejournal.com",
			      "http://www.slashdot.com",
			     ],
		    VDesktop => [0,0],
		   },
       Work => {
		Links => [
			  "http://mail.google.com",
			  "http://voice.google.com",
			  "http://calendar.google.com",
			  "http://linkedin.com",
			  "http://www.grants.gov/search",
			 ],
		VDesktop => [0,1],
	       },
      };

    foreach my $profile (keys %$profiles) {
      $self->MoveTo(
		    X => $profiles->{$profile}->{VDesktop}->[0],
		    Y => $profiles->{$profile}->{VDesktop}->[1],
		   );
      my $command = "$browser --start-maximized -P $profile -remote";
      ApproveCommands
	(
	 Commands => ["($command \&)"],
	 Method => "parallel",
	 AutoApprove => 1,
	 Simulate => $self->Simulate,
	);

      sleep 7;

      # just add a google-chrome -remote
      foreach my $site (@{$profiles->{$profile}->{Links}}) {
	my $command = "$browser --start-maximized -P $profile -remote '$site'";
	ApproveCommands
	  (
	   Commands => ["($command \&)"],
	   Method => "parallel",
	   AutoApprove => 1,
	   Simulate => $self->Simulate,
	  );
      }

      sleep 7;
    }
  }
}

#   my $applications =
#     [
#      ["gnucash",[]],


sub Launch {
  my ($self,%args) = @_;
  print Dumper(\%args);
  my $remotehostname = $args{RemoteHostname};
  my $screen = $args{Screen};
  my $maximized = $args{Maximized};
  print Dumper($maximized);
  my $vdesktop = $args{VDesktop};

  my $remotecommand;
  my $xtermcommand = "uxterm +lc";
  if (exists $args{RemoteCommand} and defined $args{RemoteCommand}) {
    $remotecommand = $args{RemoteCommand};
  } elsif (exists $args{Screen}) {
    $remotecommand = "screen -rd ".$args{Screen}." || screen -S ".$args{Screen}." emacs -nw";
    if ($args{Screen} =~ /^(root|cpm-.+)$/) {
      $xtermcommand = "xterm";
    }
  }
  $remotecommand = shell_quote($remotecommand);
  my ($x,$y) = split /,/, $vdesktop;
  # skip if there is already a desktop on this vdesktop
  my $workspaceid = ($x + 6 * $y);
  my $res = `wmctrl -l`;
  my $skip = 0;
  foreach my $line (split /\n/, $res) {
    # print $line."\n";
    if ($line =~ /^\S+\s+([0-9-]+)\s+/) {
      # print Dumper([$1,$workspaceid]);
      if ($1 == $workspaceid) {
	$skip = 1;
      }
    }
  }
  if (! $skip) {
    $self->MoveTo
      (
       X => $x,
       Y => $y,
      );
    # eventually check to see if these are already open and just open the
    # ones that aren't
    my $command;
    if ($self->LocalHostname eq $remotehostname) {
      # make sure to sudo screen -S root on columcille from columcille, etc.
      $command = "$xtermcommand $maximized -e $remotecommand";
    } else {
      my $user = "";
      if (exists $args{Screen} and $args{Screen} eq "root") { # come up with a function that checks exists, defined, and X
	$user = "root@";
      }
      $command = "$xtermcommand $maximized -e \"ssh $user$remotehostname -t $remotecommand\"";
    }
    ApproveCommands
      (
       Commands => [$command],
       Method => "parallel",
       AutoApprove => 1,
       Simulate => $self->Simulate,
      );
  }
}

sub GetLocalHostname {
  my ($self,%args) = @_;
  my $localhostname = `hostname -f`;
  chomp $localhostname;
  return $localhostname;
}

sub SetStyleWidthAndHeight {
  my ($self,%args) = @_;
  my $vdesktops = {};
  my $res = `wmctrl -d`;
  foreach my $line (split /\n/, $res) {
    if ($line =~ /^(\d+)\s+. DG: (\d+)x(\d+)/) {
      # print "<$1><$2><$3>\n";
      $vdesktops->{$1} = [$2,$3];
    }
  }
  my ($style,$width,$height);
  my $monitordimensions = [2,1];
  my $dimensions = [6,4];	# find a way to figure this out in the future

  my $numberofsmallvdesktops = $dimensions->[0] * $dimensions->[1];
  my $numvds = scalar keys %$vdesktops;
  if ($numvds == 1) {
    $style = "one";
    $width = ($vdesktops->{0}->[0] / $dimensions->[0]) / $monitordimensions->[0];
    $height = ($vdesktops->{0}->[1] / $dimensions->[1]) / $monitordimensions->[1];
  } elsif ($numvds == $numberofsmallvdesktops) {
    $style = "many";
    $width = $vdesktops->{0}->[0];
    $height = $vdesktops->{0}->[1];
  } else {
    die "confused about virtual desktop situation, number of virtual desktops is $numvds, should be 1 or $numberofsmallvdesktops\n";
  }
  $self->Style($style);
  $self->Width($width);
  $self->Height($height);
}

sub MoveTo {
  my ($self,%args) = @_;
  # wmctrl -l
  # wmctrl -i -r 0x03200024 -e 0,79,0,1841,1080; wmctrl -i -r 0x03200024 -b add,maximized_vert
  if (! (defined $self->Style and defined $self->Width and defined $self->Height)) {
    $self->SetStyleWidthAndHeight;
  }
  my $windownum = ($args{X} + (6 * $args{Y}));
  my $args;
  if ($self->Style eq "one") {
    $args = "-o ".($args{X} * $self->Width).",".($args{Y} * $self->Height);
  } elsif ($self->Style eq "many") {
    $args = "-s $windownum";
  }
  my $command = "wmctrl $args";
  ApproveCommands
    (
     Commands => [$command],
     Method => "parallel",
     AutoApprove => 1,
     Simulate => $self->Simulate,
    );
}

1;
