package Manager::Manager;

sub CheckUserState {
  my @UserStates =
    ("Emotional Status",
     "Productivity",
     "Blood Sugar");
}

sub InferUserState {

}

sub SuggestActivity {
  my @Activities =
    ("Bathroom Break",
     "RSI Break",
     "Meal",
     "Sleep",
     "Lesson",
     "Typing Tutor",
     "New Work Focus");
}

sub Daily {
  my @inquiries =
    ("Dreams",
     "Bad Influences");
}

1;

##!/bin/sh
#
#export DISPLAY=":0"
#manager="etc"
#time_manager="/home/debs/prog/manager/manager"
#xlock=`which xlock`
#xmessage=`which xmessage`
##FvwmCommand=`which FvwmCommand`
#festival=`which festival`
#sgrep=`which sgrep`
#xterm=`which xterm`
#gtypist=`which gtypist`
#
#case "$1" in
#hourly)
#    # tell to go to the bathroom, when logs out, xlock for 3 minutes of hand excersizes
#    killall $xlock #> /dev/null 2> /dev/null
#    $xlock -mode flag -message 'go #1
#refill water'  -erasedelay 0 -timeout 1 #> /dev/null 2> /dev/null
#    ((sleep $((2*60)); killall $xlock) &) #> /dev/null 2> /dev/null
#    $xlock -mode flag -message 'hand exersizes' -erasedelay 0 -timeout 1 #\
#	#> /dev/null 2> /dev/null
#;;
#sleep)
#    ps -aux --cols=300 | \
#	grep -E "$time_manager sleep|cat /boot/vmlinuz|$festival|audsp|xlock" | \
#	grep -v grep | awk '{print $2}' | grep -v "$$" |  xargs kill #> /dev/null 2> /dev/null
#    ($xmessage "$3 sec nap in $2 secs" -center -timeout 360000 &)
#    #$FvwmCommand "Style xmessage Sticky,StaysOnTop" #> /dev/null 2> /dev/null
#    sleep $(($2))
#    ((sleep $(($3))
#	ps -aux --cols=300 | \
#	grep -E "$time_manager hypnotic|$festival|audsp" | \
#	    grep -v grep | awk '{print $2}' | xargs kill \
#	    > /dev/null 2> /dev/null
#	aumix -L -f $manager/loud.aumixrc > /dev/null 2> /dev/null
#	cat $manager/wakeup.txt | $festival --tts > /dev/null 2> /dev/null
#))	#while /bin/true
#	    # N   do
#    #	    cat /boot/vmlinuz > /dev/dsp 2> /dev/null
#	# done) &)
#    #    ($time_manager hypnotic &)
#    #    $xlock -mode flag -message "$3 sec nap" -erasedelay 0 -timeout 1 \
##	> /dev/null 2> /dev/null
#;;
#kill)
#    ps -aux --cols=300 | \
#	grep -E "$time_manager sleep|cat /boot/vmlinuz|$festival|audsp|xlock" |\
#	grep -v grep | awk '{print $2}' | xargs kill #> /dev/null 2> /dev/null
#;;
#hypnotic)
#    aumix -L -f $manager/quiet.aumixrc #> /dev/null 2> /dev/null
#    for it in `cat $manager/read.list`
#	do
#	cp $manager/read.list{,.tmp}
#	links -dump $it | $festival --tts &&
#	grep -v "$it" $manager/read.list.tmp > $manager/read.list
#    done
#;;
#food)
#    killall $xlock #> /dev/null 2> /dev/null
#    $xlock -mode flag -message "prepare food" -erasedelay 0 -timeout 1 \
#	#> /dev/null 2> /dev/null
#;;
#gtypist)
#    (/usr/X11R6/bin/xterm -e "$gtypist" &)
#    sleep $(($2*60))
#    killall $gtypist
#;;
#fix-bugs)
#    emacs /sys/etc/buglist
#;;
#read-documentation)
#    ($xmessage "Read Some Documentation" -center -timeout 360000 &)
#    $FvwmCommand "Style xmessage Sticky,StaysOnTop" #> /dev/null 2> /dev/null
#;;
#*)
#    cat $0 | perl -ne '/^[\t ]*[-\w]*\)/ && print'
#;;
#esac
