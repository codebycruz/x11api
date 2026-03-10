typedef void *XDisplay;
typedef unsigned long XWindow;

typedef void *GLXContext;
typedef void *GLXFBConfig;

int glXMakeCurrent(XDisplay, XWindow, GLXContext);
void glXSwapBuffers(XDisplay, XWindow);
void glXDestroyContext(XDisplay, GLXContext);
int glXMakeContextCurrent(XDisplay, XWindow, XWindow, GLXContext);

/*  Getters */
GLXContext glXGetCurrentContext();
XDisplay glXGetCurrentDisplay();
XWindow glXGetCurrentDrawable();
void glXQueryDrawable(XDisplay dpy, XWindow draw, int attribute,
                      unsigned int *value);

/* Misc */
const char *glXQueryExtensionsString(XDisplay dpy, int screen);
void *glXGetProcAddress(const unsigned char *procname);
