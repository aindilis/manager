package Manager::AM::Sleep;

# When sleep is anticipated - initiate a question answering session to
# try to reconstruct the days events  and add them to event log.  This
# functionality is now found in RSR, should probably be moved to event
# system, or not

# When  sleep has  started,  and  the learning  phase  is initiated,  do
# numerous things.   Use voice activity  detection to detect  and record
# and sleep talking.  At the  proper time, initiate sleep learning using
# CLEAR.  Start  sbagen to control  when dream sequences start  and end.
# Play wakeup  and prompt the user  to record their  dream.  Remind them
# how much time they have to remember it all.

# But first, the planning domain should ensure that they get in bed with
# their headphones on, and verify that they can hear it.

# During awake learning modes (gtypst, etc), also run quiz

sub LoadCamera
  # sudo modprobe ovcamchip
  # sudo modprobe ov511

  # (or) sudo modprobe mod_quickcam
}

sub TimeStamp {
  # date "+%Y%m%d%H%M%S"
}

sub StartAll {
  my $live = 1;

  # kill existing processes that would interfere
  if ($live) {
    StopAll();
  }

  if ($live) {
    # system "/home/jasayne/bin/sanctus &";
  }

  # start up motion detection
  if ($live) {
    print "Starting motion detection\n";
    system "/home/jasayne/bin/arm &";
  }

  if ($live) {
    print "Starting alarm\n";
    system "/home/jasayne/bin/next-alarm.pl &";
  }

  # now choose from among the available read lists and run clair
  if ($live) {

    # instead  of just  starting clear  here  it should  plan for  the
    # nights reading / dreaming schedule

    print "Starting CLEAR\n";
    system "clear.pl -n";
  }

  if ($live) {
    print "Securing system\n";
    # system "/home/jasayne/bin/secure";
  }

  StopAll();
}

sub DreamRecorder {
  # determine  if the  user  is  asleep by  asking  them very  quietly
  # whether they  are or not, if  no response, the user  is assumed to
  # have fallen asleep, and thus the night phase begins

  # <<Sun May 15 20:53:55 EDT 2005> <Be sure to record dreams by finding
  # system that detects REM sleep and wakes me afterwards, with keyboard
  # nearby and prompts me to record dream.>>

  # SayText("Wake up, and record your dream!");

  # open emacs up to the top
}

sub StopAll {
  print "Stopping previously running programs\n";
  # system "killall -9 sleep-learning";
  system "killall -9 arm";
  system "killall -9 motion";
  system "killall -9 clair";
  system "killall -9 alarm";
}

1;
