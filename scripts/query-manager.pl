#!/usr/bin/perl -w

use PerlLib::SwissArmyKnife;
use UniLang::Util::TempAgent;

my $tempagent = UniLang::Util::TempAgent->new();

my $res1 = $tempagent->MyAgent->QueryAgent
  (
   Receiver => 'Manager',
   Data => {
	    Command => 'estimate-schedule',
	   },
  );

print Dumper($res1);
