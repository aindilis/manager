package Manager::Cycle;

# system responsible for maintaining planning cycle, i.e. with Verber.
# right now, it is mainly responsible for calculating and initiating
# isolations.

# some more features:

# manage isolation score

# have function for translating sleep schedule to a work schedule.
# For instance, if I have to start working at some time, have me go to
# bed earlier and wake up later, and do more vigorous exercises or
# something.

use Class::MethodMaker
  new_with_init => 'new',
  get_set       => [ qw / SleepSchedule / ];

sub init {
  my ($self, %args) = @_;
}

sub Execute {
  my ($self, %args) = @_;
}

sub PlanIsolations {
  my ($self, %args) = @_;

  # first, determine my next few awake and sleep times
  my $res = $UNIVERSAL::manager->PredictSleepingTimes;

  # (plan for isolation
  #  (set up website with number of consecutive days of isolation being recorded
  #   (therefore make sure you have everything))
  #  )

  # a positive score is calculate based on the number of consecutive
  # days or hours of isolation

  # this should be added through the event log system


  # calculate times for isolations


  # for simplicity, just do a start from a given time
}

sub PostIsolationSurvey {
  my ($self, %args) = @_;
  # let us determine what is needed for next time.
}

1;
