#!/bin/sh

export DISPLAY=":0"

ETCPATH="/etc/cmanager"
CMANAGERPATH="/usr/bin/cmanager"

xlock=`which xlock`
xmessage=`which xmessage`
freetts=`which freetts`
sgrep=`which sgrep`
xterm=`which xterm`
gtypist=`which gtypist`

#FvwmCommand=`which FvwmCommand`

case "$1" in
hourly)
    # tell to go to the bathroom, when logs out, xlock for 3 minutes of hand excersizes
    killall $xlock #> /dev/null 2> /dev/null
    $xlock -mode flag -message 'go #1
refill water'  -erasedelay 0 -timeout 1 #> /dev/null 2> /dev/null
    ((sleep $((2*60)); killall $xlock) &) #> /dev/null 2> /dev/null
    $xlock -mode flag -message 'hand exersizes' -erasedelay 0 -timeout 1 #\
	#> /dev/null 2> /dev/null
;;
sleep)
    ps -aux --cols=300 | \
	grep -E "$CMANAGERPATH sleep|cat /boot/vmlinuz|$festival|audsp|xlock" | \
	grep -v grep | awk '{print $2}' | grep -v "$$" |  xargs echo kill #> /dev/null 2> /dev/null
    ($xmessage "$3 sec nap in $2 secs" -center -timeout 360000 &)
    #$FvwmCommand "Style xmessage Sticky,StaysOnTop" #> /dev/null 2> /dev/null
    sleep $(($2))
    ((sleep $(($3))
	ps -aux --cols=300 | \
	grep -E "$CMANAGERPATH hypnotic|$festival|audsp" | \
	    grep -v grep | awk '{print $2}' | xargs kill \
	    > /dev/null 2> /dev/null
	aumix -L -f $ETCPATH$/loud.aumixrc > /dev/null 2> /dev/null
	$freetts -file $ETCPATH/wakeup.txt))
;;
kill)
    ps -aux --cols=300 | \
	grep -E "$CMANAGERPATH sleep|cat /boot/vmlinuz|$festival|audsp|xlock" |\
	grep -v grep | awk '{print $2}' | xargs kill #> /dev/null 2> /dev/null
;;
hypnotic)
    aumix -L -f $ETCPATH/quiet.aumixrc #> /dev/null 2> /dev/null
    for it in `cat $manager/read.list`
	do
	cp $ETCPATH/read.list{,.tmp}
	links -dump $it | $freetts
	grep -v "$it" $ETCPATH/read.list.tmp > $ETCPATH/read.list
    done
;;
food)
    killall $xlock #> /dev/null 2> /dev/null
    $xlock -mode flag -message "prepare food" -erasedelay 0 -timeout 1 \
	#> /dev/null 2> /dev/null
;;
gtypist)
    (/usr/X11R6/bin/xterm -e "$gtypist" &)
    sleep $(($2*60))
    killall $gtypist
;;
fix-bugs)
    emacs /var/lib/cmanager/buglist
;;
read-documentation)
    ($xmessage "Read Some Documentation" -center -timeout 360000 &)
    #$FvwmCommand "Style xmessage Sticky,StaysOnTop" #> /dev/null 2> /dev/null
;;
*)
    cat $0 | perl -ne '/^[\t ]*[-\w]*\)/ && print'
;;
esac
