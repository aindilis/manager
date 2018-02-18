#!/usr/bin/perl -w

# auto authenticate

# be able to slinky into things like 192.168.1.200 from outside the
# network

use Manager::Dialog qw(Approve ApproveCommands);

use Data::Dumper;

if (Approve("Load Terminals")) {
  ApproveCommands
    (
     Commands => [
		  "killall -9 xterm", # honestly, find a nicer way to terminates these .....  setanta-agent???
		 ],
     Method => "parallel",
    );

  my $vdesktops = {};
  my $res = `wmctrl -d`;
  foreach my $line (split /\n/, $res) {
    if ($line =~ /^(\d+)\s+. DG: (\d+)x(\d+)/) {
      # print "<$1><$2><$3>\n";
      $vdesktops->{$1} = [$2,$3];
    }
  }

  my $style;
  my $dimensions = [6,4];
  my $numberofsmallvdesktops = $dimensions->[0] * $dimensions->[1];
  my $numvds = scalar keys %$vdesktops;
  if ($numvds == 1) {
    $style = "one";
  } elsif ($numvds == $numberofsmallvdesktops) {
    $style = "many";
  } else {
    die "confused about virtual desktop situation, number of virtual desktops is $numvds, should be 1 or $numberofsmallvdesktops\n";
  }

  my $widthheight = "--width 1280 --height 800";

  my $preferences = {
		     "any" =>
		     [
		      "manager-jump-to -h aloysius.frdcsa.org -s user --maximized --vdesktop 1,0 --wmtype $style $widthheight",
		      "manager-jump-to -h box.posithon.org -s user --maximized --vdesktop 2,0 --wmtype $style $widthheight",
		      "manager-jump-to -h posiconsultancy.com -s user --maximized --vdesktop 3,0 --wmtype $style $widthheight",
		      "manager-jump-to -h columcille.frdcsa.org -s user --maximized --vdesktop 4,0 --wmtype $style $widthheight",
		      "manager-jump-to -h frdcsa.onshore.net -s user --maximized --vdesktop 5,0 --wmtype $style $widthheight",

		      "manager-jump-to -h aloysius.frdcsa.org -s root --maximized --vdesktop 1,1 --wmtype $style $widthheight",
		      "manager-jump-to -h box.posithon.org -s root --maximized --vdesktop 2,1 --wmtype $style $widthheight",
		      "manager-jump-to -h posiconsultancy.com -s root --maximized --vdesktop 3,1 --wmtype $style $widthheight",
		      "manager-jump-to -h columcille.frdcsa.org -s root --maximized --vdesktop 4,1 --wmtype $style $widthheight",
		      "manager-jump-to -h frdcsa.onshore.net -s root --maximized --vdesktop 5,1 --wmtype $style $widthheight",

		      "manager-jump-to -h aloysius.frdcsa.org -s cpm-user --vdesktop 0,1 --wmtype $style $widthheight",
		      "manager-jump-to -h aloysius.frdcsa.org -s cpm-work --vdesktop 0,1 --wmtype $style $widthheight",
		     ],

		     "posiconsultancy.com" =>
		     [
		      "manager-jump-to -h posiconsultancy.com -s erc-logon-1 --vdesktop 5,2 --wmtype $style $widthheight",
		      "manager-jump-to -h posiconsultancy.com -s erc-logon-2 --vdesktop 5,3 --wmtype $style $widthheight",
		      # "manager-jump-to -h posiconsultancy.com -c /home/andrewdo/bin/virtualbox --vdesktop 3,2 --wmtype $style $widthheight",
		     ],

		     "columcille.frdcsa.org" =>
		     [
		      # "manager-jump-to -h columcille.frdcsa.org -c /home/andrewdo/bin/virtualbox --vdesktop 3,2 --wmtype $style $widthheight",
		     ],
		    };

  my $hostname = `hostname -f`;
  chomp $hostname;
  my @tostart = ("any",$hostname);
  foreach my $pref (@tostart) {
    my $sleep = 2;
    foreach my $command (@{$preferences->{$pref}}) {
      print "$command\n";
      system "($command \&)";
      sleep $sleep;
      $sleep = 1;
    }
  }
}

if (Approve("Load Browser Tabs")) {
  my $browser = "google-chrome";
  ApproveCommands
    (
     Commands => [
		  "killall -9 $browser", # honestly, find a nicer way to terminates these .....  setanta-agent???
		 ],
     Method => "parallel",
    );
  my $profiles =
    {
     Projects => {
		  VDesktop => [0,1],
		  Links => [
			    "http://frdcsa.org",
			    "http://posithon.org",
			    "http://frdcsa.onshore.net/rt",
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
			    "http://www.slashdot.com",
			   ],
		  VDesktop => [0,0],
		 },
     Work => {
	      Links => [
			"http://mail.google.com",
			"http://voice.google.com",
			"http://calendar.google.com",
			"http://rt.oicom.net/rt",
			"http://www.oicom.net/library",
			"http://linkedin.com",
		       ],
	      VDesktop => [0,1],
	     },
    };

  # just add a google-chrome -remote

  foreach my $profile (keys %$profiles) {

    foreach my $site (@{$profiles->{$profile}->{Links}}) {
      my $command = "$browser -remote '$site'";
      print "$command\n";
      system "($command &)";
    }
  }
}

# open a second browser for work, rt.oicom.net, wiki.oicom.net, etc

# open a third browser instance for all kinds of other useful sites
# freshmeat. linkedin, etc.  Look at our old bookmarks of useful
# sites.  send those sites to Justin.

# open a fourth browser instance for logging onto other gmail and yahoo accounts simultaenously.

# andrewdo 21362  0.0  0.0  47592   484 pts/2    S+   Feb03   0:00 ssh -X aloysius.frdcsa.org

# do a search for a command like ssh -X $hostname or ssh $hostname,
# etc, and then get the parent process, which should be the bash or
# the uxterm, do this till you get the xterm process, then figure out
# if it is in the correct location, etc.  then use this information to
# determine whether it needs to be opened.  do the same for the
# browser, also see what browser tabs are already open, and see if I
# can rearrange tabs if needed


# then go ahead and open all the terminals and the connections
# for now just open them with a two second delay

# detect whether they are already running

# use Unix::Process;

# see how it handles virtualdesktops
# get screen resolution

# wmctrl -s <id>

# or

# wmctrl -o 3840,0

# 0  * DG: 7680x3200  VP: 5120,0  WA: 0,25 1280x750  Desk 1

# need to log in automatically
# # need the option to load one or the other
# # make the delay between switching the virtual desktopsless somehow
# # if there is no screen on the machine, start one
