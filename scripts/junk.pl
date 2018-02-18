  # call up Score and ask for a list of the
  #   my $w = $self->SelectWindow
  #     (Window => 3);
  #   my $ret = $w->[0];
  #   my $keys = $w->[1];
  #   foreach my $key (@$keys) {
  #     my $c = $self->GetEvent($ret->{$key});
  #     my $tasks = $self->LookupTasksForFile
  #       (File => $c->[2]);
  #     print Dumper($c->[1],$tasks);
  #   }
