package Manager::State;

use PerlLib::Date;

sub CheckUserState {
  my ($self, %args) = (shift,@_);
  my $userstate = $self->InferUserState;
  if ($userstate->Location eq "Computer") {
    my @UserStates =
      ("Emotional Status",
       "Productivity",
       "Blood Sugar");
  }
}

sub InferUserState {
  my ($self, %args) = (shift,@_);
  # for now simply ask the user, but eventually, motion analysis, etc,
  # to infer the users state

  # what properties are there to be inferred?
  $properties =
    {
     "they are asleep",
     "they are at the computer",
    };
}

sub CheckPresence {
  my ($self, %args) = (shift,@_);
  # see if user is currently at computer
  $self->FaceDetectHistory->{Date} = Manager::Sensor::Vision::FaceDetect();
}

1;
