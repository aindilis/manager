#!/usr/bin/perl -w

use BOSS::Config;
use Manager::Dialog;

use Data::Dumper;
use Tk;

# set the environment variable

my $mw = MainWindow->new
  (
   -title => "Bluetooth Manager",
   -height => 600,
   -width => 800,
  );

$frame = $mw->Frame(-relief => 'flat');
$frame->pack(-side => 'top', -fill => 'y', -anchor => 'center');

$menu = $mw->Frame(-relief => 'raised', -borderwidth => '1');
$menu->pack(-before => $frame, -side => 'top', -fill => 'x');

$menu_file = $menu->Menubutton(-text => 'File', -underline => 0);
$menu_file->command(-label => 'load ...', -command => sub { },
		    -underline => 0);
$menu_file->command(-label => 'Exit', -command => sub { }, -underline => 0);
$menu_file->pack(-side => 'left');

# my $photo = $mw->Photo(-file => "scater.gif");
# $photo->pack(-side => 'top', -fill => 'y', -anchor => 'center');

my $box = $mw->Listbox(
		       -relief => 'sunken',
		       -height  => 5,
		       -setgrid => 1,
		      );


my @items = qw(Jabra G1);
foreach (@items) {
  $box->insert('end', $_);
}
$box->bind('all', '<Control-c>' => \&exit);
$box->bind('<Double-Button-1>' => sub {
	     my($listbox) = @_;
	     foreach (split ' ', $listbox->get('active')) {
	       ProcessSpecification
		 (
		  Module => $_,
		  InvocationCommand => "",
		 );
	     }
	   });
my $scroll = $mw->Scrollbar(-command => ['yview', $box]);
$box->configure(-yscrollcommand => ['set', $scroll]);
$box->pack(-side => 'left', -fill => 'both', -expand => 1);
$scroll->pack(-side => 'right', -fill => 'y');
MainLoop;
