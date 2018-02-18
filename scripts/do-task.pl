#!/usr/bin/perl -w

use Manager::Dialog qw(Message QueryUser SubsetSelect);
use PerlLib::MySQL;

# just use a generic search in the future

sub AddTask {
  my $mysql = PerlLib::MySQL->new
    (DBName => "score");
  my $task = QueryUser("What is the task?");
  Message(Message => "What is the deadline?");
  my @times = SubsetSelect
    (Set =>
     [
      "By tomorrow morning",
      "By tomorrow afternoon",
      "By tomorrow evening",
      "By tomorrow night",
      "Within the next day",
      "Within the next hour",
      "Within the next minute",
      "By such and such hour",
      "As soon as this task executes",
      "Before this task",
     ]);
  Message(Message => "What is the task expected time to completion?");
  my $duration = Choose
    (
     "hour",
     "half-hour",
     "minute",
     "day",
     "week",
     "month",
    );
  # determine related tasks

  # find the best functions for task searching

  foreach my $t (@times) {
    $mysql->Insert
      (Table => "tasks",
       Values => {
		  ID => "NULL",
		  AgentID => 1,
		  Description => $task,
		  Date => "Now()",
		  Source => "NULL",
		  SourceID => "NULL",
		  EMH => ,
		  Deadline => "$t",
		  Status => "unsolved",
		 });
  }
}

sub RelateTasks {
  # relate tasks to be sub and super tasks

}

sub CheckTasks {
  # intended to be run very often, implements semantics of statements

}

sub CalculateCriticalPath {
  # based on interrelation of tasks
  # obtain a graph
}

# if we insert a goal instead of a task, simply reify it into a task
# to check on the goal
