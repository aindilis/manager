#!/usr/bin/python
from pynotify import *
import sys

def notify(message=""):
	n = Notification(sys.argv[1], message)
	n.show()

init("cli notify")
if len(sys.argv) > 2:
	notify(sys.argv[2])
else:
	notify()
