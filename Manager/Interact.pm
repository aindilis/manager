package Manager::Interact;

# this  is a  temporary dialog  system.  Too  bad  Manager::Dialog was
# taken.  I know that will get fixed soon.

# use the multiagent logics for communication

sub Request {
  # the user sends a request here
  # attempt to translate the request into a standard form

  if (1) {   # if the request is to make true some goal state, invoke the planner with this goal
    if (! $UNIVERSAL::manager->Planner->IsSatisfiable(Goal => $goal)) {
      # tell the user that the goal as stated is not satisfiable, give reason if askes
    }
    # now determine whether the goal satisfies permission
    if (! 0) {
      # tell the user that the goal as stated is not permitted, give reason if askes
    }
  }
}

sub GetUsersAttention {

}

1;
