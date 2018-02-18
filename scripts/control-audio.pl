#!/usr/bin/perl -w

# eventually need to use this:
# /var/lib/myfrdcsa/codebases/internal/manager/Manager/Sensors/Audio.pm

use BOSS::Config;
use PerlLib::SwissArmyKnife;

$specification = q(
	-a <actions>...		Audio actions to perform
	-r <rooms>...		Rooms to perform audio actions in

	-s			Simulate
);

my $config =
  BOSS::Config->new
  (Spec => $specification);
my $conf = $config->CLIConfig;
# $UNIVERSAL::systemdir = "/var/lib/myfrdcsa/codebases/minor/system";

my $simulate = exists $conf->{'-s'};

my $roomshash =
  {
   '<REDACTED>' => {
		    ip => '<REDACTED>',
		    username => 'andrewdo',
		   },
  };

foreach my $action (@{$conf->{'-a'}}) {
  foreach my $room (@{$conf->{'-r'}}) {
    my $roomhash = $roomshash->{$room};
    my $username = $roomhash->{username};
    my $ip = $roomhash->{ip};
    if ($action eq 'start-recording') {
      my $command = "/var/lib/myfrdcsa/codebases/minor/prolog-agent/scripts/remote-execution.pl -s $ip -u $username -c /home/$username/.misc/systems/meeting/rec-voice-activated.sh";
      print $command."\n";
      system $command unless $simulate;
    }
    if ($action eq 'stop-recording') {
      my $command = "/var/lib/myfrdcsa/codebases/minor/prolog-agent/scripts/remote-execution.pl -s $ip -u $username -c /home/$username/.misc/systems/meeting/stop-rec-voice-activiated.sh";
      # /home/andrewdo/.misc/systems/meeting/stop-rec-voice-activiated.sh
      print $command."\n";
      system $command unless $simulate;
    }
  }
}
