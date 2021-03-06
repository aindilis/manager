Manager

HCI-based task management, cognitive prosthesis

The user awareness component that is responsible for assisting the
user to operate on a reasonable schedule.  It communicates with
several other systems to synthesize highly logical schedules and
itineraries.  And most importantly, it monitors the user's state:
where they are, what they are doing, what their physical and
psychological conditions are, and so forth.  It is primarily
responsible for making the user aware of their environmental, needs
and responsibilities.


Manager has evolved to be a central component in the FRDCSA design,
although it isn't yet operational.

Communication with other systems involves: carrying on dialogs with
the user (Audience) to accomplish tasks (PSE) via plans (Verber) and
other planning modules (BusRoute / Event-System / Meeting / etc).
However, it must know certain things about the user's habits (RSR),
preferences (CRITIC), background knowledge (CLEAR), and environment
(PhysicalSecurity / Machiavelli), in order to synthesize coherent
schedules.

Here is a sample of the presence detection system in action:
<pre>
	Broadcast, person has arrived at 20050109211125
	Broadcast, person has departed at 20050109211131
	Broadcast, person has arrived at 20050109211141
	Broadcast, person has departed at 20050109211206
	Broadcast, person has arrived at 20050109211208
	Broadcast, person has departed at 20050109211351
	Broadcast, person has arrived at 20050109211404
</pre>

It will therefore autonomously execute certain actions: for instance,
briefing the user on destination and safety before driving, tasks upon
waking up, initiating sleep learning, reminding the user to perform
basic chores when appropriate, frequent hand exercise, bathroom and
sleep breaks, keep a polyphasic sleep schedule,

It derives much, conceptually, from the Friday and Electric Elves
system from ISI, as well as many other awareness systems.  Currently,
it interacts heavily with MKAS, and in the future will provide
capabilities to SVRE.

To quote a rather illicit source as read to me by CLEAR:

The Magician must therefore take the utmost care in the matter of
purification, "firstly", of himself, "secondly", of his instruments,
"thirdly", of the place of working.  Ancient Magicians recommended a
preliminary purification of from three days to many months.  During
this period of training they took the utmost pains with diet.  They
avoided animal food, lest the elemental spirit of the animal should
get into their atmosphere.  They practised sexual abstinence, lest
they should be influenced in any way by the spirit of the wife.  Even
in regard to the excrements of the body they were equally careful; in
trimming the hair and nails, they ceremonially destroyed the severed
portion.  They fasted, so that the body itself might destroy anything
extraneous to the bare necessity of its existence.  They purified the
mind by special prayers and conservations.  They avoided the
contamination of social intercourse, especially the conjugal kind; and
their servitors were disciples specially chosen and consecrated for
the work.

http://frdcsa.org/frdcsa/internal/manager