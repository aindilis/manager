#!/usr/bin/perl -w

use BOSS::Config;
use Manager::Sensors::Audio;
use PerlLib::SwissArmyKnife;

$specification = q(
	-r		Record Audio
	-p		Playback Audio

	-f		Do not prompt, just do it
);

my $config =
  BOSS::Config->new
  (Spec => $specification);
my $conf = $config->CLIConfig;
$UNIVERSAL::systemdir = "/var/lib/myfrdcsa/codebases/internal/manager";

my $audio = Manager::Sensors::Audio->new;
if (exists $conf->{'-r'}) {
  $audio->RecordSpeechAudio
    (
     AutoApprove => (exists $conf->{'-f'}),
    );
} elsif (exists $conf->{'-p'}) {
  $audio->PlaySpeechAudio
    ();
}

# parec | sox -t raw -r 44000 -sLb 16  -c 2 -s - -t wav temp.wav
# parec | sox -t raw -r 16000 -sLb 8  -c 1 -s - -t wav - | speexenc --rate 16000 - speech.spx
# speexdec --rate 16000 speech.spx speech.wav
# play speech.wav
