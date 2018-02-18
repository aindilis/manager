#include <tcl.h>
#include <tk.h>
#include <string.h>
#include <stdio.h>
#include <time.h>
#include <X11/X.h>
#include <X11/Xutil.h>
#include <X11/extensions/shape.h>

#define MSG(c) fprintf(stderr, "%s:%i %s\n", __FILE__, __LINE__, c);


#define XEMBED_MAPPED                   (1 << 0)
#define SYSTEM_TRAY_REQUEST_DOCK    0
#define SYSTEM_TRAY_BEGIN_MESSAGE   1
#define SYSTEM_TRAY_CANCEL_MESSAGE  2

static Window systemtray = 0;
static Display *display;

static Tk_3DBorder border = NULL;

static char* dockwin_name = "Dockwin"; // used for name in geomMgr

static void xembed_set_info (Tk_Window window, unsigned long flags)
{
   	unsigned long buffer[2];
 
	// Get flags
   	Atom xembed_info_atom = XInternAtom (display,"_XEMBED_INFO",0);
 
   	buffer[0] = 0;                // Protocol version
   	buffer[1] = flags;
 
	// Change the property
   	XChangeProperty (display,
                    Tk_WindowId(window),
                    xembed_info_atom, xembed_info_atom, 32,
                    PropModeReplace,
                    (unsigned char *)buffer, 2);
}

static void send_message( Display* dpy,Window w,
		Atom type,long message, 
		long data1, long data2, long data3)
{
    	XEvent ev;
  
    	memset(&ev, 0, sizeof(ev));
    	ev.xclient.type = ClientMessage;
    	ev.xclient.window = w;
    	ev.xclient.message_type = type;
    	ev.xclient.format = 32;
    	ev.xclient.data.l[0] = time(NULL);
    	ev.xclient.data.l[1] = message;
    	ev.xclient.data.l[2] = data1;
    	ev.xclient.data.l[3] = data2;
    	ev.xclient.data.l[4] = data3;

		//trap_errors();
    	XSendEvent(dpy, w, False, NoEventMask, &ev);
    	XSync(dpy, False);
    //if (untrap_errors()) {
	/* Handle failure */
		//printf("Handle failure\n");
    //}
}

static void resize_combine (Window w, int width, int height)
{
     XRectangle rect;

     rect.x = 0;
     rect.y = 0;
     rect.width = width;
     rect.height = height;
     XShapeCombineRectangles(display,
			     w,
			     ShapeBounding,
			     0, 0,
			     &rect,
			     1,
			     ShapeSet,
			     0);
}

static void resize (Tk_Window win,
	Tk_Window client_win)
{
     XSizeHints *hint;

     hint = XAllocSizeHints();
     hint->flags |= PMinSize;
     hint->min_width = Tk_ReqWidth(client_win); 
     hint->min_height = Tk_ReqHeight(client_win);
     
     XSetWMNormalHints(display, Tk_WindowId(win), hint);
     XFree(hint);

     resize_combine(Tk_WindowId(win),
		    Tk_ReqWidth(client_win),
		    Tk_ReqHeight(client_win));
}

static void dockwin_event(ClientData clientData, register XEvent *eventPtr)
{
     Tk_Window client_win = (Tk_Window) clientData;
     
     if (eventPtr->type == ConfigureNotify)
     {
	  XConfigureEvent* cfgEventPtr = (XConfigureEvent*) eventPtr;
	     
	  // if this window was configure (not the client)
	  if (cfgEventPtr->window == cfgEventPtr->event)
	  {
	       // resize the client window if the main window gets resized

	       Tk_ResizeWindow(client_win,
			       Tk_ReqWidth(client_win),
			       Tk_ReqHeight(client_win));

	       resize_combine(cfgEventPtr->window,
			      Tk_ReqWidth(client_win),
			      Tk_ReqHeight(client_win));
	  }
     }
     else if (eventPtr->type == UnmapNotify)
     {
	  XUnmapEvent* umEventPtr = (XUnmapEvent*) eventPtr;
	  if (umEventPtr->window != umEventPtr->event) // from client window
	  {
	       Tk_Window win = Tk_IdToWindow(display, umEventPtr->event);
	       if (win == NULL)
	       {
		    MSG("Could not find window");
		    return;
	       }
	       Tk_DestroyWindow(win);
	  }
     }
     else if (eventPtr->type == DestroyNotify)
     {
	  XDestroyWindowEvent* desEventPtr = (XDestroyWindowEvent*) eventPtr;
	  if (desEventPtr->window == desEventPtr->event) // from this window
	  {
	       Tk_DestroyWindow(client_win);
	  }
     }
}

static void dockwin_geomRequest(ClientData clientData, Tk_Window client_win)
{
     Tk_Window win = (Tk_Window)clientData;
     resize(win, client_win);
}

static void dockwin_geomLostSlave(ClientData clientData, Tk_Window client_win)
{
     Tk_Window win = (Tk_Window)clientData;
     Tk_DestroyWindow(win);
}

static int Tk_Dockwin (ClientData clientData,
	    Tcl_Interp *interp,
	    int argc,
	    Tcl_Obj *CONST argv[])
{
     Tk_Window win;
     Tk_Window client_win;
     Tk_GeomMgr* geomMgr;
     Tcl_Obj** objv;
     int i;
     XSetWindowAttributes* attr;

     if (systemtray == 0)
     {
	  Tcl_AppendResult(interp, "Systemtray not available", (char*) NULL);
	  return TCL_ERROR;
     }

     if (argc < 2)
     {
	  Tcl_WrongNumArgs(interp, 0, NULL, "dockwin name");
	  return TCL_ERROR;
     }

     win = Tk_CreateAnonymousWindow(interp, Tk_MainWindow(interp), "");

     (((Tk_FakeWin *) (win))->flags |= TK_CONTAINER); // dirty

     Tk_MakeWindowExist(win);

     xembed_set_info(win, XEMBED_MAPPED);

     send_message(display, systemtray,
		  XInternAtom(display, "_NET_SYSTEM_TRAY_OPCODE", False),
		  SYSTEM_TRAY_REQUEST_DOCK,Tk_WindowId(win), 0, 0);

     // Create inner toplevel window
     objv = (Tcl_Obj**) Tcl_Alloc((argc - 2 + 4) * sizeof(Tcl_Obj*));

     objv[0] = Tcl_NewStringObj("toplevel", -1);
     Tcl_IncrRefCount(objv[0]);
     objv[1] = argv[1];
     objv[2] = Tcl_NewStringObj("-use", -1);
     Tcl_IncrRefCount(objv[2]);
     objv[3] = Tcl_NewIntObj(Tk_WindowId(win));
     Tcl_IncrRefCount(objv[3]);

     for (i = 0; i < argc - 2; i++)
     {
	  objv[i+4] = argv[i+2];
     }

     if (Tcl_EvalObjv(interp, argc - 2 + 4, objv, 0) != TCL_OK)
     {
	  Tcl_DecrRefCount(objv[0]);
	  Tcl_DecrRefCount(objv[2]);
	  Tcl_DecrRefCount(objv[3]);
	  Tcl_Free((char*)objv);
	  Tk_DestroyWindow(win);

	  Tcl_AppendResult(interp, "\ncould not create inner window", (char*) NULL);
	  return TCL_ERROR;
     }
     Tcl_DecrRefCount(objv[0]);
     Tcl_DecrRefCount(objv[2]);
     Tcl_DecrRefCount(objv[3]);
     Tcl_Free((char*)objv);

     // Geometry Manager
     if (! (client_win = Tk_NameToWindow(interp, Tcl_GetString(argv[1]), Tk_MainWindow(interp))))
     {
	  Tk_DestroyWindow(win);

	  Tcl_AppendResult(interp, "No Dockwin", (char*) NULL);
	  return TCL_ERROR;
     }
     geomMgr = (Tk_GeomMgr*)Tcl_Alloc(sizeof(Tk_GeomMgr));
     geomMgr->name = dockwin_name;
     geomMgr->requestProc = dockwin_geomRequest;
     geomMgr->lostSlaveProc = dockwin_geomLostSlave;	  

     Tk_ManageGeometry(client_win, geomMgr, (ClientData)win);

     attr = Tk_Attributes(win);
     attr->event_mask |= StructureNotifyMask | SubstructureNotifyMask;
     Tk_ChangeWindowAttributes(win, CWEventMask, attr);

     Tk_CreateEventHandler(win, 
 			   StructureNotifyMask | SubstructureNotifyMask, 
 			   dockwin_event, 
 			   (ClientData) client_win); 

     resize(win, client_win);

#ifdef DEBUG
     fprintf(stderr, "WinID: %i\n", (int)Tk_WindowId(win));
#endif

     Tcl_SetObjResult(interp, argv[1]);
     return TCL_OK;
}

static void dockwin_delete(ClientData clientData)
{
     Tcl_Interp* interp = (Tcl_Interp*) clientData;

     Tcl_DeleteCommand(interp, "dockwin_config");

     Tk_Free3DBorder(border);
}

static int Tk_SystemTrayAvailable (ClientData clientData,
			Tcl_Interp *interp,
			int argc,
			Tcl_Obj *CONST argv[])
{
     Tcl_Obj *result;

     if (argc != 1)
     {
	  Tcl_WrongNumArgs(interp, 0, NULL, "systemtray_exists");
	  return TCL_ERROR;
     }

     if (systemtray > 0)
	  result=Tcl_NewIntObj(1);
     else
	  result=Tcl_NewIntObj(0);
     
     Tcl_SetObjResult(interp, result);
     return TCL_OK;
}

int Freedock_Init(Tcl_Interp *interp)
{
     char buffer[256];
     Atom a;
     Tk_Window mainwin;

     if (Tk_InitStubs(interp, "8.4", 0) == NULL) {
	  return TCL_ERROR;
     }

     mainwin = Tk_MainWindow(interp);
     display = Tk_Display(mainwin);

     snprintf (buffer, sizeof (buffer), "_NET_SYSTEM_TRAY_S%d",
	       XScreenNumberOfScreen(Tk_Screen(mainwin)));
     // Get the X11 Atom
     a = XInternAtom (display,buffer, False);
     // And get the window ID associated to that atom
     systemtray = XGetSelectionOwner(display,a);

     Tcl_CreateObjCommand(interp, "systemtray_exists", Tk_SystemTrayAvailable,
			  (ClientData)NULL, (Tcl_CmdDeleteProc*)NULL);

     border = Tk_Get3DBorder(interp, mainwin, "white");

     Tcl_CreateObjCommand(interp, "dockwin", Tk_Dockwin,
			  (ClientData)interp, dockwin_delete);

     Tcl_PkgProvide (interp, "Freedock", "0.1");

     return TCL_OK;
}
