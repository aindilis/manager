#!/usr/bin/perl -w

use Manager::Dialog qw(Approve);

my $games =
  {
   "/usr/games/map" => 1,
   "/usr/games/cube" => 1,
   "/usr/games/pegs" => 1,
   "/usr/games/rect" => 1,
   "/usr/games/solo" => 1,
   "/usr/games/dominosa" => 1,
   "/usr/games/samegame" => 1,
   "/usr/games/guess" => 1,
   "/usr/games/loopy" => 1,
   "/usr/games/mines" => 1,
   "/usr/games/slant" => 1,
   "/usr/games/untangle" => 1,
   "/usr/games/lightup" => 1,
   "/usr/games/sixteen" => 1,
   "/usr/games/fifteen" => 1,
   "/usr/games/blackboxgame" => 1,
   "/usr/games/netgame" => 1,
   "/usr/games/twiddle" => 1,
   "/usr/games/netslide" => 1,
   "/usr/games/pattern" => 1,
   "/usr/games/flipgame" => 1,
   "/usr/games/inertia" => 1,
   "/usr/games/ksokoban" => 4,
   "/usr/share/games/pathological/pathological.py" => 1,
   "/usr/games/pathological" => 1,
   "/usr/games/gnome-sudoku" => 1,
   "/usr/games/xtokkaetama" => 1,
   "/usr/games/xkaetama" => 1,
   "/usr/games/gnubik" => 1,
   "/usr/games/gweled" => 1,
   "/usr/games/gemdropx" => 1,
   "/usr/games/gtans" => 1,
   "/usr/games/gnudoku" => 1,
   "/usr/games/gnect" => 1,
   "/usr/games/gnomine" => 1,
   "/usr/games/same-gnome" => 1,
   "/usr/games/mahjongg" => 1,
   "/usr/games/gtali" => 1,
   "/usr/games/gnome-stones" => 1,
   "/usr/games/gataxx" => 1,
   "/usr/games/gnotravex" => 1,
   "/usr/games/gnotski" => 1,
   "/usr/games/glines" => 1,
   "/usr/games/iagno" => 1,
   "/usr/games/gnobots2" => 1,
   "/usr/games/gnibbles" => 1,
   "/usr/games/gnometris" => 1,
   "/usr/games/blackjack" => 1,
   "/usr/games/sol" => 1,
   "/usr/games/xpuyopuyo" => 1,
   "/usr/games/gcompris" => 1,
   "/usr/games/xrubik" => 1,
   "/usr/games/xskewb" => 1,
   "/usr/games/xdino" => 1,
   "/usr/games/xpyraminx" => 1,
   "/usr/games/xoct" => 1,
   "/usr/games/xmball" => 1,
   "/usr/games/xcubes" => 1,
   "/usr/games/xtriangles" => 1,
   "/usr/games/xhexagons" => 1,
   "/usr/games/xmlink" => 1,
   "/usr/games/xbarrel" => 1,
   "/usr/games/xpanex" => 1,
   "/usr/games/hrd" => 1,
   "/usr/games/xshisen" => 1,
   "/usr/bin/kanagram" => 1,
   "/usr/games/stax" => 1,
   "/usr/games/bloksi" => 1,
   "/usr/bin/gtkboard" => 1,
  };

my $total = 0;
my $map = [];
my $i = 0;
foreach my $entry (keys %$games) {
  $total += $games->{$entry};
  $map->[$i++]->{$entry} = $total;
}

# now randomize the choice

sub SelectRandomGame {
  my $rand = rand(1.0);
  my $j = 0;
  do {
    my @k = keys %{$map->[$j]};
    $ratio = $map->[$j++]->{$k[0]} / $total;
    # print "$j\t$rand\t$ratio\n";
  } while ($ratio < $rand);

  my @l = keys %{$map->[$j-1]};
  return $l[0];
}

my $game;
do {
  $game = SelectRandomGame;
} while (!Approve($game));

system $game;

