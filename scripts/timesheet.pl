#!/usr/bin/perl -w

# interpret the /tmp/context file

use Data::Dumper;

my $f1 = "/tmp/gnuplot";
my $c = `cat $f1`;
# print Dumper($c);
my $r1 = listvalues(split /\"/, $c);

my $h = {};
my $days = {};
my $f2 = "/tmp/context";
my $currentday;
my $lasttime;
foreach my $line (split /\n/, `cat $f2`) {
  my @lines = split /\s/, $line;
  my $time = shift @lines;
  my $currentday = int($time / 24.0);
  if (! $lasttime) {
    $lasttime = $time;
  }
  foreach my $e (@$r1) {
    if (defined $e) {
      $h->{$time}->{$e} = shift @lines;
      $days->{$currentday}->{$e}->{Effort} += $h->{$time}->{$e};
      if ($h->{$time}->{$e} > 0) {
	$days->{$currentday}->{$e}->{Time} += $time - $lasttime;
      }
    }
  }
  $lasttime = $time;
}

foreach my $day (sort keys %$days) {
  # figure out which day that was
  # print out the most done tasks and relate
  print "Day: $day\n";
  foreach my $key (Top($day)) {
    printf "%30s Time: %3.3f Effort: %3.3f\n",$key,$days->{$day}->{$key}->{Time},$days->{$day}->{$key}->{Effort};
  }
  # print Dumper($days->{$day});
  print "\n\n";
}

sub Top {
  my $day = shift;
  my $h = {};
  foreach my $key (keys %{$days->{$day}}) {
    if (exists $days->{$day}->{$key}->{Effort} and $days->{$day}->{$key}->{Time}) {
      $h->{$key} = $days->{$day}->{$key};
      $h->{$key}->{Total} = $h->{$key}->{Time} * $h->{$key}->{Effort};
    }
  }
  my @l = sort {$h->{$b}->{Total} <=> $h->{$a}->{Total}} keys %$h;
  return splice @l, 0, 5;
}

sub listvalues {
  my @r;
  while (@_) {
    shift;
    push @r, shift;
  }
  return \@r;
}

sub listkeys {
  my @r;
  while (@_) {
    push @r, shift;
    shift;
  }
  return \@r;
}
