package Manager;

use BOSS::Config;
use Manager::AM::Alarm;
use Manager::Dialog qw ( Message );
use Manager::Events;
use Manager::Predict;
use Manager::Records;
use Manager::Records::Context;
use Manager::Scheduler2;
use Manager::Misc::VDesktopManager;
use MyFRDCSA;
use PerlLib::Date;

use Data::Dumper;
use Mail::Message;
use Time::HiRes qw( time );

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>

  [

   qw / Config MyRecords MyPredict MyContext MyEvents MyAlarm
   MyScheduler MyVDesktopManager StartTime /

  ];

sub init {
  my ($self, %args) = (shift,@_);
  $specification = "
	--init			Initialize usual desktop configuration
	--speed <speed>		Delay between logins

	-e			Estimate time user is going to fall asleep
	-a			Turn on alarm (defaults to next alarm)
	-d <seconds>		Set alarm (delay)
	-t <time>		Set alarm (time)

	-p [<speed>]		Playback emacs -nw session
	-P <file>		Playback specific file
	-r			Record emacs -nw session
	-s			Use emacspeak instead of emacs
	--contexts		Plot task context trends
	-j [<file>]		Plot to JPEG
	--measures		Check performance measures

	--timesheet		Log timesheet hours
	--tsday <day>		Generate a timesheet log for a given day (2006-07-07)
	--tsmonth <month>	Generate a timesheet log for a given month (01..12)

	--request		Request action
	--record		Record events
	--common		Record common events

	--check			Check uncertainties of expected events

	--dailyscore		Get Daily Score
	--recent		Show Recent Events
	--plotrecent		Plot Recent Scores
	--plotdaily		Plot Daily Scores
	--plotmeasures		Plot Measures Scores

	--recompute		Recompute Scores

	-m			Monitor user
	--page <user> <subject> <data>		Page user

	--scheduler		Enable the scheduler

	-u [<host> <port>]	Run as a UniLang agent

	-w			Delay before exiting
	-W [<delay>]		Exit as soon as possible (with optional delay)
";

  $UNIVERSAL::systemdir = ConcatDir(Dir("internal codebases"),"manager");
  $self->Config(BOSS::Config->new
		(
		 Spec => $specification,
		 ConfFile => "",
		));
  my $conf = $self->Config->CLIConfig;
  if (exists $conf->{'-u'}) {
    $UNIVERSAL::agent->Register
      (Host => defined $conf->{-u}->{'<host>'} ? $conf->{-u}->{'<host>'} : "localhost",
       Port => defined $conf->{-u}->{'<port>'} ? $conf->{-u}->{'<port>'} : "9000");
  }
  if (exists $conf->{'-W'}) {
    $self->StartTime(time());
  }
}

sub Execute {
  my ($self, %args) = (shift,@_);
  my $conf = $self->Config->CLIConfig;
  if (exists $conf->{'-a'}) {
    $self->MyAlarm(Manager::AM::Alarm->new);
    if (exists $conf->{'-d'}) {
      $self->MyAlarm->SetAlarm
	(Delay => $conf->{'-d'});
    } elsif (exists $conf->{'-t'}) {
      $self->MyAlarm->SetAlarm
	(Time => $conf->{'-t'});
    } else {
      $self->MyAlarm->SetAlarm
	();
    }
  } elsif (exists $conf->{'-e'}) {
    if (! $self->MyPredict) {
      $self->MyPredict(Manager::Predict->new);
    }
    print Dumper($self->MyPredict->Execute);
  } elsif (exists $conf->{'-r'}) {
    $self->MyRecords(Manager::Records->new);
    $self->MyRecords->Record;
  } elsif (exists $conf->{'-p'}) {
    $self->MyRecords(Manager::Records->new);
    $self->MyRecords->PlayBack
      (Speed => $conf->{-p},
       File => $conf->{-P});
  } elsif (exists $conf->{'--init'}) {
    if (! $self->MyVDesktopManager) {
      $self->MyVDesktopManager(Manager::Misc::VDesktopManager->new);
    }
    $self->MyVDesktopManager->LoadDefaults(Speed => $conf->{'--speed'});
  } elsif (exists $conf->{'--vision'}) {
    $self->MyVision
      (Manager::Sensors::Vision->new);
  } elsif (exists $conf->{'--contexts'}) {
    if (! $self->MyContext) {
      $self->MyContext
	(Manager::Records::Context->new());
    }
    $self->MyContext->PlotTaskContextTrends
      (OutputFormat => $conf->{-j} ? "jpeg" : undef,
       OutputFile => $conf->{-j} ? $conf->{-j} : undef);;
  } elsif (exists $conf->{'--timesheet'}) {
    if (! $self->MyContext) {
      $self->MyContext
	(Manager::Records::Context->new());
    }
    $self->MyContext->LogHours;
  } elsif (exists $conf->{'--tsday'}) {
    if (! $self->MyContext) {
      $self->MyContext
	(Manager::Records::Context->new());
    }
    $self->MyContext->GenerateTimesheetLogForDay
      (Day => $conf->{'--tsday'});
  } elsif (exists $conf->{'--tsmonth'}) {
    if (! $self->MyContext) {
      $self->MyContext
	(Manager::Records::Context->new());
    }
    $self->MyContext->GenerateTimesheetLogForMonth
      (Month => $conf->{'--tsmonth'});
  } elsif (exists $conf->{'--measures'}) {
    if (! $self->MyContext) {
      $self->MyContext
	(Manager::Records::Context->new());
    }
    $self->MyContext->Measures;
  } elsif (exists $conf->{'--plotmeasures'}) {
    if (! $self->MyContext) {
      $self->MyContext
	(Manager::Records::Context->new());
    }
    $self->MyContext->PlotMeasures
      (OutputFormat => $conf->{-j} ? "jpeg" : undef,
       OutputFile => $conf->{-j} ? $conf->{-j} : undef);
  } elsif (exists $conf->{'--plotdaily'}) {
    if (! $self->MyEvents) {
      $self->MyEvents
	(Manager::Events->new());
    }
    $self->MyEvents->PlotDailyScores
      (OutputFormat => $conf->{-j} ? "jpeg" : undef,
       OutputFile => $conf->{-j} ? $conf->{-j} : undef);
  } elsif (exists $conf->{'--page'}) {
    # since we don't have a real system up for storing user
    # information, simply use a file
    my $users = {
		 "Andrew Dougherty" => "6304141131\@cingularme.com",
		};
    my $user = $conf->{'--page'}->{'<user>'};
    if (exists $users->{$user}) {
      my $nm = Mail::Message->build
	(
	 To     => $users->{$user},
	 Subject   => $conf->{'--page'}->{'<subject>'},
	 data   => $conf->{'--page'}->{'<data>'},
	);
      # print Dumper($nm);
      $nm->send;
      # also print using the popup window
    }
  } elsif (exists $conf->{'--scheduler'}) {
    # ensure there aren't multiple instances of manager running

    # send a message to frdcsa-applet to restart

    if (! $self->MyScheduler) {
      $self->MyScheduler
	(Manager::Scheduler2->new());
    }
    $self->MyScheduler->Execute;
  }
  if (exists $conf->{'-u'}) {
    # enter in to a listening loop
    if ($conf->{'-m'} and ! $self->MyContext) {
      $self->MyContext
	(Manager::Records::Context->new());
    }
    my $i = 10;
    while (1) {
      if (exists $conf->{'-m'} and $i >= 2) {
	$i = 0;
	$UNIVERSAL::agent->SendContents
	  (Contents => Dumper($self->MyContext->Check),
	   Receiver => "ELog");
      }
      $UNIVERSAL::agent->Listen(TimeOut => 10);

      if (exists $conf->{'-W'}) {
	my $delay = $conf->{'-W'} || 1000;
	$delay = $delay / 1000.0;

	if (time() > ($self->StartTime + $delay)) {
	  $UNIVERSAL::agent->Deregister;
	  exit(0);
	}
      }

      $i++;
    }
  }

  if (exists $conf->{'-w'}) {
    Message(Message => "Press any key to quit...");
    my $t = <STDIN>;
  }
}

sub ProcessMessage {
  my ($self,%args) = (shift,@_);
  my $m = $args{Message};
  my $it = $m->Contents;
  if ($it) {
    if ($it =~ /^echo\s*(.*)/) {
      $UNIVERSAL::agent->SendContents
	(Contents => $1,
	 Receiver => $m->Sender);
    } elsif ($it =~ /^(quit|exit)$/i) {
      $UNIVERSAL::agent->Deregister;
      exit(0);
    }
  }
  my $d = $m->Data;
  if ($d->{Command} =~ /^estimate-schedule$/i) {
    if (! $self->MyPredict) {
      $self->MyPredict(Manager::Predict->new);
    }
    $UNIVERSAL::agent->QueryAgentReply
      (
       Message => $m,
       Data => {
		_DoNotLog => 1,
		Result => $self->MyPredict->Execute,
	       },
      );
  }
}

1;
