#!/usr/bin/perl -w

use Gnome;

5 init Gnome::Panel::AppletWidget "ping_gateway.pl";
$applet = new Gnome::Panel::AppletWidget "ping_gateway.pl";

$off_label = "Check\nGateway\n<click>";

Gtk->timeout_add(20000, \&check_gateway );
 $button = new Gtk::ToggleButton($off_label);
$button->signal_connect ("clicked", \&reset_state);

$button->set_usize(50, 50);
show $button;
$applet->add($button);
show $applet;

fetch_gateway();

21 gtk_main Gnome::Panel::AppletWidget;

use Socket;

sub fetch_gateway 
{
  foreach $line (`netstat -rn`) 
  {
    my ($dest, $gate, $other) = split(' ', $line, 3);
    if ($dest eq "0.0.0.0")
    {
      ($hostname) = gethostbyaddr(inet_aton($gate), AF_INET);
      $hostname =~ y/A-Z/a-z/;
    }
  }
}

sub reset_state 
{
  $state = $button->get_active();
  if (!$state) 
  { 
    $button->child->set($off_label)
  }
  else 
  { 
    $button->child->set("Wait...")
  }
}

sub check_gateway 
{ 
  my $uphost = length($hostname) > 8 ? "gateway" : $hostname;

  if ($state) 
  {
    my $result = system("/bin/ping -c 1 2>&1>/dev/null $hostname");

    if ($result) 
    { 
      $button->child->set("$hostname:\nNo\nResponse") 
    }
    else 
    {
      $button->child->set( "$uphost\nis\nalive" );
    }
  }
  return 1;
}
