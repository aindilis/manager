(related files
 /s1/myfrdcsa/codebases/releases/manager-0.1/manager-0.1/Manager/Scheduler2.pm
 /s1/myfrdcsa/codebases/releases/manager-0.1/manager-0.1/Manager/Misc/NotificationManager.pm
)

(have it so that notification manager routinely checks for a
 different version of unilang, in case it is restarted or what
 not)

(completed (ensure that it creates new ids for each of the items))

(for the scheduler, we need the following...
 (have it say what the priority and due-date of the task is)
 (have it flash tasks which are overdue or something like that)
 (have it color differently tasks that are almost due)

 (allow us to mark an item as complete)
 (when the thing is restarted, it should redisplay the various
  tasks)
 (in other words it needs to reconstruct from the context)

 (when there is a new item, it should flash the icon until we click on it)

 (it should handle multiple items with the same name according to
  the entry ids instead of the name, or something like that) 

 (should implement rollover)

 (should even be sensitive to interactive execution management if possible)

 (when it gets a message, it should not resize it to a ridiculous size)
 )




(create a Manager::Dialog partition function, which allows you to divide a set
 into a set of partitions)

(we should have a system which tracks what are incompatible uses
 - for instance, I can't both be reading a book using Clear and
 also be reading rss feeds using clear at the same time.)
