package Manager::Misc::NotificationManager;

use BOSS::Config;
use Manager::Misc::NotificationManager::Notification;
use Manager::Misc::NotificationManager::Section;
use PerlLib::Collection;
use UniLang::Util::TempAgent;

use Data::Dumper;
use Tk;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / MyMainWindow MyTempAgent MyFrame MyMenuFrame MyButtonFrame
   MyScrollFrame MyBox MyEntries MySections MyMenu Withdrawn
   SectionColor MyApplet /

  ];

sub init {
  my ($self,%args) = @_;
  $self->MyApplet($args{Applet});
  $self->MyMainWindow
    ($args{MainWindow} || MainWindow->new
     (
      -title => "Notification Manager",
      -height => 600,
      -width => 800,
     ));
  $self->MyFrame
    ($self->MyMainWindow->Frame(-relief => 'flat'));

  $self->MyFrame->pack
    (-side => 'top', -fill => 'y', -anchor => 'center');
  $self->MyMenuFrame
    ($self->MyMainWindow->Frame(-relief => 'raised', -borderwidth => '1'));
  $self->MyMenuFrame->pack(-before => $self->MyFrame, -side => 'top', -fill => 'x');

  $menu_file = $self->MyMenuFrame->Menubutton(-text => 'File', -underline => 0, -tearoff => 0);
  $menu_file->command(-label => 'Exit', -command => sub { }, -underline => 0);
  $menu_file->pack(-side => 'left');

  $menu_view = $self->MyMenuFrame->Menubutton(-text => 'View', -underline => 0, -tearoff => 0);
  $menu_view->command(-label => 'Recently Completed', -command => sub { }, -underline => 0);
  $menu_view->command(-label => 'Filters', -command => sub { }, -underline => 0);
  $menu_view->pack(-side => 'left');

  $self->MyMainWindow->title
    ( "FRDCSA Notification Manager" );
  $self->MyButtonFrame
    ($self->MyMainWindow->Frame());
  $self->MyButtonFrame->Button
    (
     -text => "Clear",
     -command => sub { $self->ClearAllNotifications() },
    )->pack(-side => "right");
  $self->MyButtonFrame->pack
    (
     -fill => "both",
     -expand => 1,
    );

  $self->MyMenu
    ($self->MyMainWindow->Menu(-tearoff => 0));
  $self->MyMenu->add('command', -label => 'Dismiss Menu', -command => sub {});
  $self->MyMenu->add
    (
     'command',
     -label => 'Open',
     -command => sub {
       my %args = @{$self->LastTags};
       # if this is open, I will want to send a message to SPSE to
       # open this task...

       # for now just crudely start it, a kind of developer
       # visualization of eventual behavior

     },
    );
  $self->MyMenu->add('command', -label => 'Mark Completed', -command => sub {});
  $self->MyMenu->add('command', -label => 'Cancel Task', -command => sub {});
  $self->MyMenu->add('command', -label => 'Hide Node', -command => sub {});
  $self->MyMenu->add('command', -label => 'Similarity Search', -command => sub {});
  $self->MyMenu->add('command', -label => 'Explain Holdup', -command => sub {});
  $self->MyMenu->add('command', -label => 'Add Subtasks', -command => sub {});
  $self->MyMenu->add('command', -label => 'Dispute Task', -command => sub {});

  $self->MyTempAgent
    (UniLang::Util::TempAgent->new
     (
      Name => "Notification-Manager",
      ReceiveHandler => sub {
	$self->ProcessMessage(@_);
      },
     ));

  $self->MyEntries
    (PerlLib::Collection->new
     (
      Type => "Manager::Misc::NotificationManager::Notification",
     ));
  $self->MyEntries->Contents({});
  $self->MySections
    (PerlLib::Collection->new
     (
      Type => "Manager::Misc::NotificationManager::Section",
     ));
  $self->MySections->Contents({});
}

sub Execute {
  my ($self,%args) = @_;
  $self->PopulateSampleNotifications();
  $self->MyMainLoop();
}

sub MyMainLoop {
  my ($self,%args) = @_;
  # print Dumper({Applet => $self->MyApplet});
  # $self->MyApplet->Execute();
  my $conf = $UNIVERSAL::frdcsaapplet->Config->CLIConfig;
  if (exists $conf->{'-W'}) {
    $self->MyMainWindow->repeat
      (
       $conf->{'-W'} || 1000,
       sub {
	 $UNIVERSAL::agent->Deregister;
	 exit(0);
       },
      );
  }
  $self->MyMainWindow->repeat
    (
     50,
     sub {
       $self->AgentListen(),
     },
    );
  MainLoop();
}

sub AgentListen {
  my ($self,%args) = @_;
  # UniLang::Agent::Agent
  # print ".\n";
  $self->MyTempAgent->MyAgent->Listen
    (
     TimeOut => 0.05,
    );
}

sub ReloadNotifications {
  my ($self,%args) = @_;

}

sub PopulateSampleNotifications {
  my ($self,%args) = @_;
  my @sections =
    (
     Manager::Misc::NotificationManager::Section->new
     (
      Description => "Ongoing",
      Type => "Ongoing",
      Color => "green",
      SectionColor => "pale green",
     ),
     Manager::Misc::NotificationManager::Section->new
     (
      Description => "Notifications",
      Type => "Notifications",
      Color => "red",
      SectionColor => "pink",
     ),
    );

  my $entries =
    {
     "Ongoing" =>
     [
      "Sync: Too many calendar deletes. 7:22 AM",
     ],
     Notifications =>
     [
      "Missed Call: Unknown  8:32 PM",
      "New email: 3 unread (Yahoo) 9:48 PM",
      "Download finished: \"Oro Se Do Bheartha Bhaile\" 10:32 PM",
     ],
    };

  foreach my $section (@sections) {
    $self->AddSection
      (
       Section => $section,
      );
  }

  foreach my $section (keys %$entries) {
    foreach my $entry (@{$entries->{$section}}) {
      my $notification = Manager::Misc::NotificationManager::Notification->new
	(
	 Description => $entry,
	 Type => $section,
	);
      $self->AddNotification
	(
	 DoNotAnnounce => 1,
	 Notification => $notification,
	 DoNotRedraw => 1,
	);
    }
  }
  $self->Redraw();
}

sub AddNotification {
  my ($self,%args) = @_;
  # display notification

  # also reason about the state of the user, whether they are engaged,
  # and the importance of the message etc. -- adjustable autonomy

  if (! $args{DoNotAnnounce}) {
    $args{Notification}->Announce
      (
       Title => "FRDCSA Notification Manager",
       Contents => $args{Notification}->Description,
      );
    $self->MyMainWindow->deiconify();
    $self->MyMainWindow->raise();
    $self->Withdrawn(0);
  }

  # FIXME obvious problem here with colliding descriptions
  $self->MyEntries->Add
    (
     $args{Notification}->Description => $args{Notification},
    );
  if (! exists $self->MySections->Contents->{$args{Notification}->{Type}}) {
    print "No section found for this, putting in general...\n";
    # do this later
  } else {
    $self->MySections->Contents->{$args{Notification}->{Type}}->MyEntries->Add
      (
       $args{Notification}->Description => $args{Notification},
      );
  }
  $self->Redraw() unless $args{DoNotRedraw};
}

sub Redraw {
  my ($self,%args) = @_;
  # in the future this will be more complex, there should a sorted
  # type, with priority, etc

  if (defined $self->MyScrollFrame) {
    $self->MyScrollFrame->destroy;
  }

  $self->MyScrollFrame
    ($self->MyMainWindow->Frame);
  $self->MyBox
    ($self->MyScrollFrame->Listbox
     (
      -relief => 'sunken',
      -width  => 80,
      -setgrid => 1,
     ));
  $self->MyBox->bind('all', '<Control-c>' => \&exit);
  $self->MyBox->bind
    (
     'all',
     '<3>' => sub {
       my ($listbox) = @_;
       my $description = $listbox->get('active');

       # get the lcoation of the mouse event, and open
       # a menu, that allows you to do such things as
       # open it up in SPSE
       my $Ev = $listbox->XEvent;
       $self->MyMenu->post($Ev->X,$Ev->Y);

       if (exists $self->MyEntries->Contents->{$description}) {
	 # okay here is the notification, act on it

	 # pretend we are acting on it

	 # for now, open SPSE to it

       }
       # self->ProcessSpecification
       #  (
       #   Program => $_,
       #   InvocationCommand => "",
       #  );
       # system "/var/lib/myfrdcsa/codebases/minor/spse/scripts/launch-spse.sh"
     });
  my $scroll = $self->MyScrollFrame->Scrollbar(-command => ['yview', $self->MyBox]);
  $self->MyBox->configure(-yscrollcommand => ['set', $scroll]);
  $self->MyBox->pack(-side => 'left', -fill => 'both', -expand => 1);
  $scroll->pack(-side => 'right', -fill => 'both');
  $self->MyScrollFrame->pack
    (
     -fill => "both",
     -expand => 1,
    );

  foreach my $section ($self->MySections->Values) {
    my $itemid = $self->MyBox->insert('end', $section->Description);
    $self->MyBox->itemconfigure('end', -background => $section->Color);
    foreach my $notification ($section->MyEntries->Values) {
      $self->MyBox->insert('end', $notification->Description);
      $self->MyBox->itemconfigure('end', -background => $section->SectionColor);
    }
  }
  $self->MyMainWindow->geometry("80x10");
}

sub AddSection {
  my ($self,%args) = @_;
  $self->MySections->Add
    (
     $args{Section}->Description => $args{Section},
    );
}

sub ProcessMessage {
  my ($self,%args) = @_;
  my $m = $args{Message};

  if (exists $m->Data->{Action}) {
    if ($m->Data->{Action} eq "Add") {
      if (exists $m->Data->{Description}) {
	my $notification = Manager::Misc::NotificationManager::Notification->new
	  (
	   Type => $m->Data->{Type},
	   Description => $m->Data->{Description},
	   Priority => $m->Data->{Priority},
	  );
	$self->AddNotification
	  (
	   Notification => $notification,
	  );
      }
    }
  } else {
    my $it = $m->Contents;
    if ($it) {
      if ($it =~ /^echo\s*(.*)/) {
	$UNIVERSAL::agent->SendContents
	  (Contents => $1,
	   Receiver => $m->Sender);
      } elsif ($it =~ /^(quit|exit)$/i) {
	$UNIVERSAL::agent->Deregister;
	exit(0);
      } elsif ($it =~ /^restart$/i) {
	$self->MyApplet->Restart();
      }
    }
  }
}

sub ClearAllNotifications {
  my ($self,%args) = @_;
  foreach my $key ($self->MyEntries->Keys) {
    my $notification = $self->MyEntries->Contents->{$key};
    $notification->Clear();
    $self->MyEntries->SubtractByKey($key);
  }
  foreach my $section ($self->MySections->Values) {
    foreach my $key ($section->MyEntries->Keys) {
      my $notification = $section->MyEntries->Contents->{$key};
      $notification->Clear();
      $section->MyEntries->SubtractByKey($key);
    }
  }
  $self->Redraw();
}

1;

# # Setup a unilang agent that listens for messages, and adds them here

# $UNIVERSAL::agent = UniLang::Agent::Agent->new
#   (Name => "Notification-Manager",
#    ReceiveHandler => \&Receive);

# sub Receive {
#   my %args = @_;
#   # $UNIVERSAL::dashboard->ProcessMessage
#   # (Message => $args{Message});
# }

# # $mw->repeat(100,sub {});
# MainLoop;
