typedef void *XDisplay;
typedef unsigned long XWindow;
typedef unsigned long XAtom;
typedef int XBool;
typedef int XStatus;
typedef void *XVisual;
typedef unsigned long XColormap;
typedef void *XScreen;
typedef unsigned long XTime;
typedef unsigned long XCursor;

typedef struct {
  int type;
  unsigned long serial;
  XBool send_event;
  XDisplay display;
  XWindow window;
  XAtom message_type;
  int format;
  union {
    char b[20];
    short s[10];
    long l[5];
  } data;
} XClientMessageEvent;

typedef struct {
  int type;
  unsigned long serial;
  XBool send_event;
  XDisplay display;
  XWindow window;
  int x, y;
  int width, height;
  int count;
} XExposeEvent;

typedef struct {
  int type;
  unsigned long serial;
  XBool send_event;
  XDisplay display;
  XWindow event;
  XWindow window;
  int x, y;
  int width, height;
  int border_width;
  XWindow above;
  XBool override_redirect;
} XConfigureEvent;

typedef struct {
  int type;
  unsigned long serial;
  XBool send_event;
  XDisplay display;
  XWindow window;
  XWindow root;
  XWindow subwindow;
  XTime time;
  int x, y;
  int x_root, y_root;
  unsigned int state;
  char is_hint;
  XBool same_screen;
} XMotionEvent;

typedef struct {
  int type;
  unsigned long serial;
  XBool send_event;
  XDisplay display;
  XWindow window;
  XWindow root;
  XWindow subwindow;
  XTime time;
  int x, y;
  int x_root, y_root;
  unsigned int state;
  unsigned int button;
  XBool same_screen;
} XButtonEvent;

typedef unsigned long XKeySym;

typedef struct {
  int type;
  unsigned long serial;
  XBool send_event;
  XDisplay display;
  XWindow window;
  XWindow root;
  XWindow subwindow;
  XTime time;
  int x, y;
  int x_root, y_root;
  unsigned int state;
  unsigned int keycode;
  XBool same_screen;
} XKeyEvent;

typedef struct {
  int type;
  unsigned long serial;
  XBool send_event;
  XDisplay display;
  XWindow window;
} XAnyEvent;

typedef union {
  int type;
  XAnyEvent xany;
  XClientMessageEvent xclient;
  XExposeEvent xexpose;
  XConfigureEvent xconfigure;
  XKeyEvent xkey;
  XMotionEvent xmotion;
  XButtonEvent xbutton;
  long pad[24];
} XEvent;

typedef struct {
  int x, y;
  int width, height;
  int border_width;
  int depth;
  XVisual visual;
  XWindow root;
  int class;
  int bit_gravity;
  int win_gravity;
  int backing_store;
  unsigned long backing_planes;
  unsigned long backing_pixel;
  XBool save_under;
  XColormap colormap;
  XBool map_installed;
  int map_state;
  long all_event_masks;
  long your_event_mask;
  long do_not_propagate_mask;
  XBool override_redirect;
  XScreen screen;
} XWindowAttributes;

XDisplay XOpenDisplay(const char *display_name);
int XCloseDisplay(XDisplay display);
void XDestroyWindow(XDisplay display, unsigned long window);
XWindow XDefaultRootWindow(XDisplay display);
XWindow XCreateSimpleWindow(XDisplay display, XWindow parent, int x, int y,
                            unsigned int width, unsigned int height,
                            unsigned int border_width, unsigned long border,
                            unsigned long background);
void XMapWindow(XDisplay display, XWindow w);
XAtom XInternAtom(XDisplay display, const char *atom_name,
                  XBool only_if_exists);
XStatus XSetWMProtocols(XDisplay display, XWindow w, XAtom *protocols,
                        int count);
void XNextEvent(XDisplay display, XEvent *event_return);
void XPeekEvent(XDisplay display, XEvent *event_return);
int XDefaultScreen(XDisplay display);
int XPending(XDisplay display);
void XSelectInput(XDisplay display, XWindow w, long event_mask);
XStatus XGetWindowAttributes(XDisplay display, XWindow w,
                             XWindowAttributes *window_attributes_return);
XCursor XCreateFontCursor(XDisplay display, unsigned int shape);
void XDefineCursor(XDisplay display, XWindow w, XCursor cursor);
void XUndefineCursor(XDisplay display, XWindow w);
void XFreeCursor(XDisplay display, XCursor cursor);
void XFlush(XDisplay display);
void XChangeProperty(XDisplay display, XWindow w, XAtom property, XAtom type,
                     int format, int mode, const unsigned char *data,
                     int nelements);

XStatus XSendEvent(XDisplay display, XWindow w, XBool propagate,
                   long event_mask, XEvent *event_send);

void XSync(XDisplay display, XBool discard);

XKeySym XKeycodeToKeysym(XDisplay display, unsigned int keycode, int index);
int XLookupString(XKeyEvent *event_struct, char *buffer_return, int bytes_buffer,
                  XKeySym *keysym_return, void *status_in_out);

int XWarpPointer(XDisplay display, XWindow src_w, XWindow dest_w,
                 int src_x, int src_y, unsigned int src_width,
                 unsigned int src_height, int dest_x, int dest_y);

XBool XQueryPointer(XDisplay display, XWindow w, XWindow *root_return,
                    XWindow *child_return, int *root_x_return, int *root_y_return,
                    int *win_x_return, int *win_y_return,
                    unsigned int *mask_return);

int XGrabPointer(XDisplay display, XWindow grab_window, XBool owner_events,
                 unsigned int event_mask, int pointer_mode, int keyboard_mode,
                 XWindow confine_to, XCursor cursor, XTime time);

int XUngrabPointer(XDisplay display, XTime time);

int XGrabKeyboard(XDisplay display, XWindow grab_window, XBool owner_events,
                  int pointer_mode, int keyboard_mode, XTime time);

XKeySym *XGetKeyboardMapping(XDisplay display, unsigned int first_keycode,
                             int keycode_count, int *keysyms_per_keycode_return);

int XUngrabKeyboard(XDisplay display, XTime time);

char *XServerVendor(XDisplay display);

int XResizeWindow(XDisplay display, XWindow w, unsigned int width, unsigned int height);
int XMoveWindow(XDisplay display, XWindow w, int x, int y);

int XStoreName(XDisplay display, XWindow w, const char *window_name);
XStatus XFetchName(XDisplay display, XWindow w, char **window_name_return);
int XFree(void *data);
