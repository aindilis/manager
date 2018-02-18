#!/usr/bin/perl -w

use strict;
use Gtk2;
use Tk;

my $mw = MainWindow->new(-title=>'Tk Window');

Gtk2->init;

my $window = Gtk2::Window->new('toplevel');
$window->set_title('Gtk2 Window');
my $glabel = Gtk2::Label->new("This is a  Gtk2 Label");
$window->add($glabel);
$window->show_all;

my $tktimer = $mw->repeat(10, sub{      
   Gtk2->main_iteration while Gtk2->events_pending;
  });

$mw->Button(-text=>'     Quit     ',
       -command => sub{exit}
        )->pack();

MainLoop;
