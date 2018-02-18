#!/usr/bin/perl -w

use Gnome2::PanelApplet;

# Initialize.
Gnome2::Program->init ('My Applet', '0.01', 'libgnomeui', sm_connect => FALSE);

# Register our applet with that bonobo thingy.  The OAFIID stuff is
# specified in a .server file.  See
# C<examples/GNOME_PerlAppletSample.server> in the
# I<Gnome2::PanelApplet> tarball for an example.
Gnome2::PanelApplet::Factory->main (
				    'OAFIID:PerlSampleApplet_Factory', # iid of the applet
				    'Gnome2::PanelApplet', # type of the applet
				    \&fill # sub that populates the applet
				   );

sub fill {
  my ($applet, $iid, $data) = @_;

  # Safety measure: if we're passed the wrong IID, just return.
  if ($iid ne 'OAFIID:PerlSampleApplet') {
    return FALSE;
  }

  # Gnome2::PanelApplet isa Gtk2::EventBox, so it isa Gtk2::Container
  # in particular.  That means we can call add() on it.
  my $label = Gtk2::Label->new ('Hi, there!');
  $applet->add ($label);
  $applet->show_all;

  return TRUE;
}
