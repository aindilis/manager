package Manager::Records;

use Manager::Dialog qw (Choose QueryUser);
use Manager::Records::Session;
use MyFRDCSA qw(ConcatDir);
use PerlLib::Collection;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       => [ qw / BaseDir CurrentSession Sessions / ];

sub init {
  my ($self, %args) = @_;
  $self->BaseDir($args{BaseDir} || ConcatDir($UNIVERSAL::systemdir,"data"));
  $self->Sessions
    (PerlLib::Collection->new
     (Type => "String",
      StorageFile => $args{StorageFile} ||
      ConcatDir($self->BaseDir,"emacs-logs/.sessions")));
  $self->Sessions->Load;
}

sub Record {
  my ($self, %args) = @_;
  if (! $self->CurrentSession) {
    $self->SelectSession;
  }
  $self->CurrentSession->Start;
  $self->Sessions->Save;
}

sub PlayBack {
  my ($self, %args) = @_;
  if ($args{File}) {
    my $s = Manager::Records::Session->new
      (Name => "Name",
       Description => "Description",
       StorageFile => $args{File});
    $s->PlayBack(%args);
  } else {
    foreach my $s (@{$self->ChooseSessions}) {
      $s->PlayBack
	(%args);
    }
  }
}

sub ChooseSessions {
  my ($self, %args) = @_;
  return $self->Sessions->ChooseValuesByProcessor
    (Processor => sub {$_->Name});
}

sub SelectSession {
  my ($self, %args) = @_;
  my @choices = ("New", "Old");
  my $res = Choose(@choices);
  my $s;
  if ($res eq "New") {
    my $date = `date "+%Y%m%d%H%M%S"`;
    chomp $date;
    my $f = $self->GetNewSessionStorageFiles;
    my $f1 = $f->{StorageFile};
    my $f2 = $f->{DribbleFile};
    $s = Manager::Records::Session->new
      (StorageFile => $f1,
       DribbleFile => $f2,
       Date => $date);
    $self->Sessions->Add($s->StorageFile => $s);
  } else {
    my $s = $self->ChooseSessions->[0];
  }
  $self->CurrentSession($s);
}

sub GetNewSessionStorageFiles {
  my ($self, %args) = @_;
  my $dir = $self->BaseDir;
  my $max = 0;
  foreach my $x (split /\n/,`ls $dir/emacs-logs/ttyrec/*.ttyrec*`) {
    if ($x =~ /\/([0-9]+)\.ttyrec(\.gz)?$/) {
      if ($max < $1) {
	$max = $1;
      }
    }
  }
  ++$max;
  return {
	  StorageFile => "$dir/emacs-logs/ttyrec/$max.ttyrec",
	  DribbleFile => "$dir/emacs-logs/dribble/$max.dribble",
	 };
}

sub Classify {
  my ($self, %args) = @_;
  # this will  allow us to  segment/classify sessions using  Corpus as
  # the browser
}

1;
