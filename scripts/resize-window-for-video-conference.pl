#!/usr/bin/perl -w

use BOSS::Config;
use PerlLib::SwissArmyKnife;

use X11::WMCtrl;

$specification = q(
	-v		Set up for video conferencing
	-u		Unset video conferencing
);

my $config =
  BOSS::Config->new
  (Spec => $specification);
my $conf = $config->CLIConfig;
# $UNIVERSAL::systemdir = "/var/lib/myfrdcsa/codebases/minor/system";

my $wmctrl = X11::WMCtrl->new;
# my @windows = $wmctrl->get_windows;
# print Dumper(\@windows);
# my $workspaces = $wmctrl->get_workspaces;
# print Dumper($workspaces);

# MVARG g,x,y,w,h


# here is how the adjustment is to take place, compute all the windows



my $res = $wmctrl->wmctrl('-p -G -l');
foreach my $line (split /\n/, $res) {
  my @ref = split /\s+/, $line;
  shift @ref;
  shift @ref;
  my ($pid, $x, $y, $w, $h, @rest) = @ref;
  print "$pid $x+${y}_${w}x$h\n";
}

# if (! exists $conf->{'--or'}) {

# }

# printf("window manager is %s\n", $wmctrl->get_window_manager->{name});

# my @windows = $wmctrl->get_windows;

# $wmctrl->switch(1);

# my $app = $windows[0]->{title};

# $wmctrl->maximize($app);
# $wmctrl->unmaximize($app);
# $wmctrl->shade($app);
# $wmctrl->unshade($app);

# $wmctrl->close($app);


