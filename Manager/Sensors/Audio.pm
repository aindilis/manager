package Manager::Sensors::Audio;

use Manager::Dialog qw(ApproveCommands);
use MyFRDCSA qw(ConcatDir);
use PerlLib::SwissArmyKnife;

use IO::File;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>

  [

   qw / RecordingsDirectory /

  ];

sub init {
  my ($self,%args) = @_;
  $self->RecordingsDirectory
    ($args{RecordingsDirectory} ||
     ConcatDir
     ($UNIVERSAL::systemdir,"data","sound-recordings"));
}

sub RecordSpeechAudio {
  my ($self,%args) = @_;
  my $recordingsdir = $self->RecordingsDirectory;
  my $res = MkDirIfNotExists(Directory => $recordingsdir);
  if (! $res->{Success}) {
    print Dumper($res);
    return $res;
  }
  my @logs = split(/\s+/,`ls $recordingsdir/rec*.spx`);
  $max = 0;
  foreach $log (@logs) {
    $log =~ /.*?([0-9]+)\.spx$/;
    if ($1 > $max) {
      $max = $1;
    }
  }
  my $command1 = "parec | sox -t raw -r 44000 -sLb 16  -c 2 -s - -t wav -r 16000 -  | speexenc - $recordingsdir/rec" . ($max + 1) .".spx";
  if (ApproveCommands
    (
     Commands => [$command1],
     Method => "parallel",
     AutoApprove => $args{AutoApprove},
    )) {
    my $fh = IO::File->new;
    my $datafile = "$recordingsdir/metadata".($max + 1).".txt";
    $fh->open(">$datafile") or warn "Cannot open metadata file\n";
    my $date = `date`;
    chomp $date;
    print $fh $date;
    $fh->close();
  }
}

sub PlaySpeechAudio {
  my ($self,%args) = @_;
  my $recordingsdir = $self->RecordingsDirectory;
  my @files = split(/\s+/,`ls $recordingsdir/rec*.spx`);
  my $file = Choose(@files);
  if (-f $file) {
    ApproveCommands
      (
       Commands => [
		    "speexdec ".shell_quote($file)." /tmp/temp.wav",
		    "play /tmp/temp.wav",
		   ],
       Method => "parallel",
      );
  }
}

1;
