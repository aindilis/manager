#!/usr/bin/perl
use warnings;
use strict;
use Gtk2::TrayIcon;

Gtk2->init;

my $icon= Gtk2::TrayIcon->new("test");
$icon->add( Gtk2::Label->new("test") );
$icon->show_all;

Gtk2->main;
