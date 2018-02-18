sub SuggestActivity {
  my ($self, %args) = (shift,@_);
  my %Activities =
    ("Bathroom Break" => sub {},
     "RSI Break" => sub {},
     "Meal" => sub {},
     "Sleep" => sub {},
     "Lesson" => sub {},
     "Typing Tutor" => sub {},
     "New Work Focus" => sub {});
  my @list = keys %Activities;
  if ($self->Match($args{Activity},\@list)) {
    &{$Activities{$args{Activity}}};
  } else {
    Message(Message => "Activity not registered.");
  }
}

sub Match {
  my ($self, $regex, $list) = (shift,@_);
  #print "<".@$list.">\n";
  return scalar grep eval "/^$regex\$/", @$list;
}

sub Daily {
  my ($self, %args) = (shift,@_);
  my @inquiries =
    ("Dreams",
     "Bad Influences");
}

sub Hourly {
  my ($self, %args) = (shift,@_);
  $self->SuggestActivity(Activity => "Bathroom Break");
  $self->SuggestActivity(Activity => "Hand Exercises");
}

sub SecureSystems {
  my ($self, %args) = (shift,@_);
  # $self->SecureRemoteSystems;
  system "~/bin/secure";
}

sub SecureRemoteSystems {
  my ($self, %args) = (shift,@_);
  system "(ssh ajd\@192.168.1.20 'export DISPLAY=:0; ~/bin/secure' &)";
}

sub Sleep {
  my ($self, %args) = (shift,@_);
  my $userstate = $self->InferUserState;
  if ($userstate->SleepCycle eq "Sleeping") {

  } elsif ($userstate->Location eq "Computer") {
    if ($self->InferUserState->()) {
      if ($self->SuggestActivity(Activity => "Sleep")) {
	$self->ScheduleActivity(Activity => "Daily Debrief");
	$self->ScheduleActivity(Activity => "Learning During Sleep");
      }
    }
  }
}

sub SleepLearning {
  my ($self, %args) = (shift,@_);

}

sub Food {
  my ($self, %args) = (shift,@_);

}

sub Gtypist {
  my ($self, %args) = (shift,@_);

}

sub FixBugs {
  my ($self, %args) = (shift,@_);

}

sub ReadDocumentation {
  my ($self, %args) = (shift,@_);

}

sub ProcessCommand {
  my ($self, %args) = (shift,@_);

}

sub Send {
  my ($self, $contents) = (shift,shift);
  my $conf = $self->Config->CLIConfig;
  if (exists $conf->{'-u'}) {
    $message = UniLang::Util::Message->new(Sender => $UNIVERSAL::agent->Name,
					   Receiver => "UniLang",
					   Date => $UNIVERSAL::agent->GetDate,
					   Contents => $contents);
    $UNIVERSAL::agent->Send(Handle => $UNIVERSAL::agent->Client,
			    Message => $message);
  } else {
    Message(Message => "$contents");
  }
}
