#!/usr/bin/perl -w

use UniLang::Util::TempAgent;

use Data::Dumper;
use Schedule::Cron;
# use Schedule::Cron::Events;
use String::ShellQuote;

# connect to unilang, send a message unilang as needed here
# don't worry about it performing correctly when it is shut off, for now

my $agent = UniLang::Util::TempAgent->new(Name => "Todo-Scheduler");

my $cron = new Schedule::Cron(\&dispatcher);

# send it to unilang-client for forwarding?, but what if there is no unilang-client?

sub RunCron {
  my $cronfile = "/var/lib/myfrdcsa/codebases/internal/manager/systems/todo/data/crontab";
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
      print "$datespec\n";
      $cron->add_entry($datespec, arguments => \%data2);
    }
  }

  # $cron->run(detach=>1);
  $cron->run;
}

sub dispatcher {
  my %args = @_;
  my %args2 = %{$args{arguments}};
  my $date = `date`;
  chomp $date;
  my $duein = $args2{DueIn};
  my $c = "Agenda: <".$args2{Task}."> <".$args2{Desc}."> $date";
  print "$c\n";
  my $quotedc = shell_quote($c);
  $agent->Send
    (Contents => $c);
  my $entryid = `/var/lib/myfrdcsa/codebases/internal/freekbs/scripts/lookup-entry.pl unilang messages Contents ID $quotedc`;
  chomp $entryid;
  my $d = "KBS, MySQL:freekbs:default assert (\"due-date-for-entry\" \"$entryid\" \"$duein\")";
  print "$d\n";
  $agent->Send
    (Contents => $d);
}

RunCron;
