package Manager::Sensors::Vision;

use Manager::Dialog qw (Message);

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [ qw / FaceDetectionResults Continue / ];

sub init {
  my ($self, %args) = (shift,@_);
}

sub Start {
  my ($self, %args) = (shift,@_);
  $self->Continue(1);
  $self->FaceDetectionResults([1,1,1,1,1]);
  $self->Continuous;
}

sub End {
  my ($self, %args) = (shift,@_);
}

sub Continuous {
  my ($self, %args) = (shift,@_);
  my $last = 0;
  while ($self->Continue) {
    my $res = $self->DetectPresence;
    if ($res != $last) {
      $last = $res;
      # just really, adopt this to a confidence
      if ($last) {
	# this is the resume
# 	$self->Send
# 	  (Recipient => "CLEAR",
# 	   Message => "p");
# 	$self->Send
# 	  (Recipient => "Emacs-Client",
# 	   Message => "ps Manager: User has arrived");
	$self->Send
	  (Message => "Emacs-Client, ps Manager: User has arrived");
      } else {
	# this is the pause
# 	$self->Send
# 	  (Recipient => "CLEAR",
# 	   Message => "p");
# 	$self->Send
# 	  (Recipient => "Emacs-Client",
# 	   Message => "ps Manager: User has departed");
	$self->Send
	  (Message => "Emacs-Client, ps Manager: User has departed");
	# system "~/bin/secure &";
      }
    }
    sleep 1;
  }
}

sub Send {
  my ($self, %args) = (shift,@_);
  my $conf = $UNIVERSAL::manager->Config->CLIConfig;
  if (exists $conf->{'-u'}) {
    $message = UniLang::Util::Message->new
      (Sender => $UNIVERSAL::agent->Name,
       Receiver => $args{Recipient} || "UniLang",
       Date => $UNIVERSAL::agent->GetDate,
       Contents => $args{Message});
    $UNIVERSAL::agent->Send(Handle => $UNIVERSAL::agent->Client,
			    Message => $message);
  } else {
    Message(Message => $args{Message});
  }
}

sub DetectPresence {
  my ($self, %args) = (shift,@_);
  my $latest = $self->FaceDetect;
  unshift @{$self->FaceDetectionResults}, $latest;
  # print "Latest<$latest>";
  my $total = 0;
  my $i = 0;
  my $j = 0;
  foreach my $result (@{$self->FaceDetectionResults}) {
    ++$i;
    $total += $result;
  }
  my $score = $total / $i;;
  # print "Score<$score> I<$i> J<$j> Total<$total>\n";
  if (scalar @{$self->FaceDetectionResults} > 4) {
    pop @{$self->FaceDetectionResults};
  }
  if ($score > 0.25) {
    # person is here
    # print "Person is here\n";
    return 1;
  }
  return 0;
}

sub FaceDetect {
  my ($self, %args) = (shift,@_);
  my $command = "vgrabbj -f /tmp/temp.jpg > /dev/null 2> /dev/null \&\& ".
    "/var/lib/myfrdcsa/codebases/internal/manager/src/mydetect /tmp/temp.jpg";
  my $output = `$command`;
  if ($output =~ /Face detected/smi) {
    return 1;
  }
  return 0;
}

# sub Motion {
#   my ($self, %args) = (shift,@_);
#   # track user  motion, if the user  is not moving for  greater than a
#   # specified sum, lock the system,  and shut down any services to the
#   # user.  A very stupid for of monitorying.

#   # also ssh in to the remote system and lock that too.
#   my $MOTION;
#   open(MOTION,"motion -f 1 |") or
#     die "Cannot open motion";
#   while (1) {
#     if ($self->InputWaiting(\*MOTION)) {
#       $self->DischargeInput(\*MOTION);
#       $timeoflastmovement = Time();
#     }
#     if ((Time() - $timeoflastmovement) > 1000) {
#       $self->SecureSystems;
#     }
#   }
# }

1;
