#!/usr/bin/perl -w

use BOSS::Config;
use Manager::Dialog;

use Data::Dumper;
use Time::HiRes qw(gettimeofday tv_interval usleep);
use Tk;

my $defaultenabled = {
		      "Jabra BT620s" => 1,
		     };

my $addresstoname = {};
my $nametoaddress = {};
my $lastvalue = 0;

my $mw = MainWindow->new
  (
   -title => "Manager Bluetooth Security",
   -height => 600,
   -width => 800,
  );

$frame = $mw->Frame(-relief => 'flat');
$frame->pack(-side => 'top', -fill => 'y', -anchor => 'center');

$menu = $mw->Frame(-relief => 'raised', -borderwidth => '1');
$menu->pack(-before => $frame, -side => 'top', -fill => 'x');

$menu_file = $menu->Menubutton(-text => 'File', -underline => 0);
$menu_file->command(-label => 'load ...', -command => sub { },
		    -underline => 0);
$menu_file->command(-label => 'Exit', -command => sub { }, -underline => 0);
$menu_file->pack(-side => 'left');

my $box = $mw->Listbox(
		       -relief => 'sunken',
		       -height  => 5,
		       -setgrid => 1,
		      );

UpdateDeviceList();

my $preoptions = $mw->Frame;
my $enable = $preoptions->Checkbutton
  (
   -text => "Enable",
   -command => sub { },
  );
$enable->pack(-fill => "x");
# $enable->select;
$preoptions->pack;

my $options = $mw->Frame;
my @items = sort keys %$nametoaddress;
foreach my $item (@items) {
  # print $item."\n";
  my $checkbutton = $options->Checkbutton
    (
     -text => $item,
     -command => sub { },
    );
  $checkbutton->pack(-fill => "x");
  if (exists $defaultenabled->{$item}) {
    $checkbutton->select;
  }
}
$options->pack();

my $sensitivity = $mw->Frame;
my $s1 = $sensitivity->Frame;
my $min = 0;
my $max = 20;
my $cutofflabel = $s1->Label
  (
   -text => "Cutoff",
   -width => 20,
  )->pack(-side => "left");
my $cutoff = $s1->Scale
  (
   -orient => "horizontal",
   -from => $min,
   -to => $max,
  )->pack(-side => "right");
$cutoff->set(8);
$s1->pack(-side => "top");
my $s2 = $sensitivity->Frame;
my $distancelabel = $s2->Label
  (
   -text => "Approximate Distance",
   -width => 20,
  )->pack(-side => "left");
my $distance = $s2->Scale
  (
   -orient => "horizontal",
   -from => $min,
   -to => $max,
   -state => "disabled",
  )->pack(-side => "right");
$s2->pack(-side => "top");
$sensitivity->pack;

MyMainLoop();

sub MyMainLoop {
  my %args = @_;
  $mw->repeat(1000, sub {Check()});
  MainLoop();
}

sub Check {
  foreach my $item (@{GetCheckedAddresses()}) {
    my $address = $item->{Address};
    my $res = `hcitool rssi $address`;
    if ($res =~ /^RSSI return value: (.+)\s*$/) {
      my $value = abs($1);
      if ($value != $lastvalue) {
	# print $value."\n";
	$distance->configure(-state => "normal");
	$distance->set($value);
	$distance->configure(-state => "disabled");
      }
      $lastvalue = $value;
      if ($value > $cutoff->get()) {
	if (defined $enable->{Value} and $enable->{Value} == 1) {
	  system "gnome-screensaver-command --lock";
	}
      }
    } else {
      print "ERROR\n";
    }
  }
}

sub UpdateDeviceList {
  my $res = `hcitool con`;
  # print Dumper($res);
  my @matches = $res =~ /([0-9A-F][0-9A-F]:[0-9A-F][0-9A-F]:[0-9A-F][0-9A-F]:[0-9A-F][0-9A-F]:[0-9A-F][0-9A-F]:[0-9A-F][0-9A-F])/;
  foreach my $address (@matches) {
    GetName(Address => $address);
  }
}

sub GetName {
  my %args = @_;
  if (! exists $addresstoname->{$args{Address}}) {
    my $name = `hcitool name $args{Address}`;
    chomp $name;
    $addresstoname->{$args{Address}} = $name;
    $nametoaddress->{$name} = $args{Address};
  }
  return $addresstoname->{$args{Address}};
}

sub GetCheckedAddresses {
  my @addresses;
  foreach my $child ($options->children) {
    # print Dumper($child);
    if (defined $child->{Value} and $child->{Value} == 1) {
      my $name = $child->cget('-text');
      push @addresses, {
			Name => $name,
			Address => $nametoaddress->{$name},
		       };
    }
  }
  return \@addresses;
}

# the systray applet should open the frdcsa-dashboard

# also set the distance threshold for locking

# convert this to use Manager::Dialog after we update-frdcsa-git sync

# have option to have it reenable when we come back within range

# have an option to set the number of milliseconds for polling

# add a delay before it relocks it

# misc info
# sudo /etc/init.d/bluetooth restart
