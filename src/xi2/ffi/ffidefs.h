typedef void *XDisplay;
typedef unsigned long XWindow;

/* XIEventMask passed to XISelectEvents */
typedef struct {
  int deviceid;
  unsigned char *mask;
  int mask_len;
} XIEventMask;

/* Double-precision valuator value */
typedef struct {
  int    mask_len;
  unsigned char *mask;
  double *values;
} XIValuatorState;

/* Raw pointer/button event (XI_RawMotion, XI_RawButtonPress, XI_RawButtonRelease) */
typedef struct {
  int           type;
  unsigned long serial;
  int           send_event;
  XDisplay      display;
  int           extension;
  int           evtype;
  unsigned long time;
  int           deviceid;
  int           sourceid;
  int           detail;
  int           flags;
  XIValuatorState valuators;
  double       *raw_values;
} XIRawEvent;

int XISelectEvents(XDisplay display, XWindow window,
                   XIEventMask *masks, int num_masks);
