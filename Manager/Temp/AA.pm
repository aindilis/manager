package Manager::AA;

# this is the Adjustable Autonomy code for manager.

# more specifically, this is the part of manager that eventually
# ensures that all communications with the user takes place.
# Therefore, it is responsible for reasoning about strategies for
# finding the user.  There are different interfaces and therefore the
# ability to launch code is important.  It probably makes sense to
# either solve this problem using conformant planning, or with Spark.


# for simplicity!, we go with an abbreviated system.



# here are some use cases


# okay, we have a sequence of messages from various systems

# what is the cost of failing to acknowledge a message by a certain time

# therefore, there must be a model of timeliness of information


# there should be expected cost and variance.



# either the user has been typing or not

# if the user has been typing, we might try contacting


# one thing is we can try all interactions at once


# another is we can have the user report when he is leaving, when he
# is unplugging somehting.


# eventually we will have plans that the user is following.  it is
# during those plans that the user is contacted.

# what we want to avoid

# suppose the user has an important meeting, but leaves without a
# trace.  when the meeting comes up, we try to confirm his knowledge
# of the situation, but he cannot be reached.

# Q: or suppose he is out and an urgent message comes in, what do we
# do.  A: have a contingency for contacting the user and also
# determining ahead of time whether radio silence is acceptable, in
# other words, transfer control to another decision making entity.

# therefore the user should be kept aware ahead of time of upcoming
# scheduled items, etc.

# also, if he attempts to leave, this should be detected and any
# relevant information exchanged, (where he is going, how long he is
# going to be gone for, etc.)

# therefore, his audience, if contacted, may choose to disclose that
# the user is gone.

# all of this might be modelled like a chess game?

# more informatin:


# suppose that the user has a task

#   set up filing cabinet

#   that this task relies on a task - asking mom where cabinet items are
#   but that the items

  
1;
