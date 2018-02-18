package Manager::Records::Session;

use Manager::Dialog qw (ApproveCommands QueryUser);

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / Name Description Date StorageFile Finished Contents Tokens DribbleFile /

  ];

sub init {
  my ($self, %args) = @_;
  $self->Name($args{Name} || QueryUser("Name?:"));
  $self->Description($args{Description} || QueryUser("Description?:"));
  $self->Date($args{Date} || "");
  $self->StorageFile($args{StorageFile} || "");
  $self->DribbleFile($args{DribbleFile} || "");
  $self->Finished(0);
}

sub Start {
  my ($self, %args) = @_;
  # determine if this is a new session or not
  my $conf = $UNIVERSAL::manager->Config->CLIConfig;
  my $command;
  if (exists $conf->{-s}) {
    $command = "emacspeak -nw";
  } else {
    # $command = "emacs -nw -f manager-open-dribble-file";
    $command = "emacs -nw";
  }
  if (-f $self->StorageFile.".gz") {
    # old one
    system "gunzip ".$self->StorageFile.".gz";
    my $c = "ttyrec -a ".$self->StorageFile." -e \"$command\"";
    system $c;
  } else {
    # new one
    my $c = "ttyrec ".$self->StorageFile." -e \"$command\"";
    system $c;
  }
  $self->End;
}

sub End {
  my ($self, %args) = @_;
  # zip storage file
  if (0) {
    push @c, "gzip ".$self->StorageFile;
    ApproveCommands(@c);
  } else {
    system "gzip ".$self->StorageFile;
  }
}

sub PlayBack {
  my ($self, %args) = @_;
  my $tmpfile = "/tmp/emacs.ttyrec";
  my $c;
  if (-f $self->StorageFile.".gz") {
    $c = "gunzip -d -c \"".$self->StorageFile.".gz\" > $tmpfile";
  } else {
    $c = "cat \"".$self->StorageFile."\" > $tmpfile";
  }
  print "$c\n";
  system $c;
  $c = "rxvt -geometry 179x66+0+34 -e ttyplay ".
    ($args{Speed} ? "-s ".$args{Speed}." " : "").
      "\"$tmpfile\"";
  print "$c\n";
  system $c;
  system "reset";
}

sub Tokenize {
  my ($self, %args) = @_;
  if ($self->Finished) {
    if (! $self->Contents) {
      my $file = $self->StorageFile;
      my $c = `cat "$file"`;
      $self->Contents($c);
    }
    foreach my $w (split /[^a-zA-Z]+/,$c) {
      $self->Tokens->{$w} = 1;
    }
  }
}

1;
