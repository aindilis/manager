#!/usr/bin/perl -w

use PerlLib::SwissArmyKnife;

use X11::WMCtrl;

my $wmctrl = X11::WMCtrl->new();

print Dumper($wmctrl->get_windows());
