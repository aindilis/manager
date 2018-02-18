package Manager::Scheduler2::GoalEditor;

use Do::ListProcessor3;
use KBS2::Client;
use PerlLib::SwissArmyKnife;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       => [ qw / Context MyListProcessor MyClient / ];

sub init {
  my ($self,%args) = @_;
  $self->Context($args{Context});
  $self->MyClient(KBS2::Client->new(Context => $self->Context));
  $self->MyListProcessor
    (Do::ListProcessor3->new
     (
      PerformManualClassification => 1,
      Context => $self->Context,
     ));
}

sub CreateGoal {
  my ($self,%args) = @_;
  my $description = $args{Description};
  my $goals = {};
  my $res = $self->MyListProcessor->GenerateStatementsAbout
    (
     Self => $self,
     Domain => $description,
     ReturnEntries => 1,
    );
  foreach my $entry (@{$res->{Entries}}) {
    foreach my $assertion (@{$entry->{Assertions}}) {
      if ($assertion->[0] eq "goal") {
	$goals->{$assertion->[1]->[2]} = $assertion->[1];
      }
    }
  }
  if ($res->{Success}) {
    my $res2 = $self->ModifyAxiomsCautiously
      (
       Entries => $res->{Entries},
      );
  }
  return {
	  Success => 1,
	  Result => $goals,
	 };
}

sub ModifyAxiomsCautiously {
  my ($self,%args) = @_;
  # I guess this whole thing has to be done at once
  # try to assert all the goals
  #  if a given goal cannot be asserted, see if we should unasserted
  #  either it, or any of it's negation-invariants
  #  prompt the user for any non-monotonic changes to the KB
  # finish asserting all goals

  #  perhaps this could be accomplished by asserting in a parallel
  #  context, testing, and then deleting the original and renaming the
  #  parallel, or perhaps it could be accomplished with genls
  #  contexts, i.e. assert it in a context inheriting from the changed
  #  context and the original context

  my $entries = $args{Entries};
  my $changes = 0;
  foreach my $entry (@{$args{Entries}}) {
    foreach my $unassertion (@{$entry->{Unassertions}}) {
      my %sendargs =
	(
	 Unassert => [$unassertion],
	 Context => $self->Context,
	 QueryAgent => 1,
	 InputType => "Interlingua",
	 Flags => {
		   AssertWithoutCheckingConsistency => 1,
		  },
	);
      print Dumper(\%sendargs);
      my $res = $self->MyClient->Send(%sendargs);
      print Dumper($res);
      $changes = 1;
    }
    foreach my $assertion (@{$entry->{Assertions}}) {
      my %sendargs =
	(
	 Assert => [$assertion],
	 Context => $self->Context,
	 QueryAgent => 1,
	 InputType => "Interlingua",
	 Flags => {
		   AssertWithoutCheckingConsistency => 1,
		  },
	);
      print Dumper(\%sendargs);
      my $res = $self->MyClient->Send(%sendargs);
      print Dumper($res);
      $changes = 1;
    }
    foreach my $function (@{$entry->{Functions}}) {
      print Dumper($function->());
      $changes = 1;
    }
  }
  return {
	  Success => 1,
	  Changes => $changes,
	 };
}

sub AddEntryPart2 {
  my ($self,%args) = @_;
  return {
	  Success => 1,
	  Name => $args{Description},
	 };
}

1;
