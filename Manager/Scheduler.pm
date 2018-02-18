package Manager::Scheduler;

use Data::Dumper;
use Schedule::Cron;
# use Schedule::Cron::Events;
use String::ShellQuote;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       => [ qw / CronFile MyCron / ];

sub init {
  my ($self,%args) = @_;
  # connect to unilang, send a message unilang as needed here
  # don't worry about it performing correctly when it is shut off, for now

  $self->CronFile($args{CronFile} || "/var/lib/myfrdcsa/codebases/internal/manager/systems/todo/data/crontab");
  $self->MyCron(Schedule::Cron->new(\&Dispatcher));
  my $cronfile = $self->CronFile;
  foreach my $line (split /\n/, `cat "$cronfile"`) {
    if ($line =~ /^\s*\#/) {
      # comment line
    } elsif ($line =~ /^(.+?)\s+(\{.*\})\s*$/) {
      my $datespec = $1;
      my $data = $2;
      my $VAR1 = undef;
      eval "\$VAR1 = $data;";
      my %data2 = %$VAR1;
      $VAR1 = undef;
      $self->MyCron->add_entry($datespec, arguments => \%data2);
    }
  }
}

sub Execute {
  my ($self,%args) = @_;
  $self->MyCron->run;
}

sub Dispatcher {
  my (%args) = @_;
  my %args2 = %{$args{arguments}};
  my $date = `date`;
  chomp $date;
  my $duein = $args2{DueIn};
  my $c = "Agenda: <".$args2{Task}."> <".$args2{Desc}."> $date";
  print "$c\n";
  my $quotedc = shell_quote($c);
  $UNIVERSAL::agent->SendContents
    (Contents => $c);
  my $entryid = `/var/lib/myfrdcsa/codebases/internal/freekbs/scripts/lookup-entry.pl unilang messages Contents ID $quotedc`;
  chomp $entryid;
  my $d = "KBS, MySQL:freekbs:default assert (\"due-date-for-entry\" \"$entryid\" \"$duein\")";
  print "$d\n";
  $UNIVERSAL::agent->SendContents
    (Contents => $d);
}

1;
