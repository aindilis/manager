#!/usr/bin/perl -w

use BOSS::Config;
use PerlLib::MySQL;
use PerlLib::SwissArmyKnife;

$specification = q(
	<room>...	Rooms
);

my $config =
  BOSS::Config->new
  (Spec => $specification);
my $conf = $config->CLIConfig;

my $rooms2ip =
  {
   'crawl space' => 240,
   'computer room (facing east)' => 241,
   'upstairs computer room' => 242,
   'computer room (facing south)' => 243,
   'garage south' => 244,
   'garage north' => 245,
  };

my $ip;
foreach my $name (@{$conf->{'<room>'}}) {
  my $chosen;
  if (exists $rooms2ip->{$name}) {
    $chosen = $name;
  } else {
    my @matches;
    foreach my $key (%$rooms2ip) {
      if ($key =~ /$name/) {
	push @matches, $key;
      }
    }
    $chosen = Choose(sort @matches);
  }
  if (defined $chosen) {
    ViewCam(IP => '192.168.1.'.$rooms2ip->{$chosen});
  } else {
    die "No Camera chosen\n";
  }
}

sub ViewCam {
  my (%args) = (@_);

  my $seccamfile = '/etc/myfrdcsa/config/security-cameras';
  my $auth = "";
  if (-f $seccamfile) {
    $auth = read_file($seccamfile);
    chomp $auth;
  }
  print "$auth\n";
  print "$args{IP}\n";
  system "(cvlc http://$auth\@$args{IP}/video/mjpg.cgi &)";
}
