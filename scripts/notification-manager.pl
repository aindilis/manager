#!/usr/bin/perl -w

use BOSS::Config;
use UniLang::Agent::Agent;
use UniLang::Util::Message;

use Data::Dumper;
use Tk;

my $top1 = MainWindow->new
  (
   -title => "Notification Manager",
   -height => 600,
   -width => 800,
  );

$frame = $top1->Frame(-relief => 'flat');
$frame->pack(-side => 'top', -fill => 'y', -anchor => 'center');

$menu = $top1->Frame(-relief => 'raised', -borderwidth => '1');
$menu->pack(-before => $frame, -side => 'top', -fill => 'x');

$menu_file = $menu->Menubutton(-text => 'File', -underline => 0);
$menu_file->command(-label => 'load ...', -command => sub { },
		    -underline => 0);
$menu_file->command(-label => 'Exit', -command => sub { }, -underline => 0);
$menu_file->pack(-side => 'left');

$top1->title( "Model" );

$buttonframe = $top1->Frame();
$buttonframe->Button
  (
   -text => "Clear",
   -command => sub { },
  )->pack(-side => "right");
$buttonframe->pack
  (
   -fill => "both",
   -expand => 1,
  );

my $scrollframe = $top1->Frame;
my $box = $scrollframe->Listbox(
				-relief => 'sunken',
				-width  => 80,
				-setgrid => 1,
			       );
my @items = (
	     "Ongoing",
	     "Sync: Too many calendar deletes. 7:22 AM",
	     "Notifications",
	     "Missed Call: Unknown  8:32 PM",
	     "New email: 3 unread (Yahoo) 9:48 PM",
	     "Download finished: \"Oro Se Do Bheartha Bhaile\" 10:32 PM",
	    );
foreach (@items) {
  $box->insert('end', $_);
}
$box->bind('all', '<Control-c>' => \&exit);
$box->bind('<Double-Button-1>' => sub {
	     my($listbox) = @_;
	     my $active = $listbox->get('active');
	     print Dumper($active);
	   });
my $scroll = $scrollframe->Scrollbar(-command => ['yview', $box]);
$box->configure(-yscrollcommand => ['set', $scroll]);
$box->pack(-side => 'left', -fill => 'both', -expand => 1);
$scroll->pack(-side => 'right', -fill => 'both');
$scrollframe->pack
  (
   -fill => "both",
   -expand => 1,
  );


# Setup a unilang agent that listens for messages, and adds them here

$UNIVERSAL::agent = UniLang::Agent::Agent->new
  (Name => "Notification-Manager",
   ReceiveHandler => \&Receive);

sub Receive {
  my %args = @_;
  # $UNIVERSAL::dashboard->ProcessMessage
  # (Message => $args{Message});
}

# $mw->repeat(100,sub {});
MainLoop;
