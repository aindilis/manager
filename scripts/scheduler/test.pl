#!/usr/bin/perl -w

use Manager::Scheduler2::GoalEditor;
use PerlLib::SwissArmyKnife;

my $goaleditor = Manager::Scheduler2::GoalEditor->new
  (
   Context => "Org::FRDCSA::Manager::Scheduler2",
  );

my $res = $goaleditor->CreateGoal
  (
   Description => $ARGV[0],
  );

print Dumper({Final => $res});
