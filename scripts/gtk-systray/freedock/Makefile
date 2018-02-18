# This file contains GNU Make specific syntax. If your
# system isn't GNU/Linux, run gmake instead of make


# Path to the includes of X. This is the default
# on almost any platform
XINCLUDES = -I/usr/X11R6/include

# Path to the includes of tcl. Adjust this to match
# your system. This directory must contain tcl.h
TCLINCLUDES = -I/usr/local/include/tcl8.4

# Path to the includes of tk. Adjust this to match
# your system. This directory must contain tk.h
TKINCLUDES = -I/usr/local/include/tk8.4 

# Lib tclstub name
LIBTCLSTUB = -ltclstub8.4
# for BSD you will need
#LIBTCLSTUB = -ltclstub84

INCLUDES = $(XINCLUDES) $(TCLINCLUDES) $(TKINCLUDES) 
CFLAGS = -Wall $(INCLUDES)
LDFLAGS = -L/usr/local/lib $(LIBTCLSTUB) -L/usr/X11R6/lib -lXext

# If you have a NetBSD system, you probably need this line instead
# of the above
#LDFLAGS = -L/usr/pkg/lib -ltclstub84 -L/usr/X11R6/lib -lXext -Wl,-R/usr/pkg/lib -Wl,-R/usr/X11R6/lib

all: libfreedock.so

libfreedock.so: freedock.c
	$(CC) -shared $(CFLAGS) -DUSE_TCL_STUBS $(LDFLAGS) -o $@ $^

clean:
	rm -f libfreedock.so
