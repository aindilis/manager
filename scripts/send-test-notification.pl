#!/usr/bin/perl -w

use PerlLib::SwissArmyKnife;
use UniLang::Util::TempAgent;

my $tempagent = UniLang::Util::TempAgent->new
  (
   RandName => "Notification-Manager-Tester-",
  );

my $description = $ARGV[0] || "This is another test.";
print Dumper($description);
$tempagent->Send
  (
   Receiver => "Notification-Manager",
   Data => {
	    Action => "Add",
	    Type => "Notifications",
	    Description => $description,
	   },
  );

# add the ability to choose what type of alarm is played
# a one off alarm

# a continuous until responded to alarm

# system should know if sound is on, if headphones are plugged in, etc

# system should route alerts to phone and have them answerable via the
# Android-FRDCSA-Client

# look into dyndns.org for android phone

# http://l6n.org/android/market.php?destination=http://market.android.com/search?q=pname:org.l6n.dyndns

# http://code.google.com/p/android-xmlrpc/source/browse/branches/XMLRPC-r15/src/org/xmlrpc/android/XMLRPCServer.java?r=16

# afc-1.dyndns.org

# http://freshmeat.net/projects/android-scripting-environment
