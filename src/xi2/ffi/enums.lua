---@class x11.xi2.Enums
local xi2 = {}

---@enum x11.xi2.EventType
xi2.EventType = {
	DeviceChanged    = 1,
	KeyPress         = 2,
	KeyRelease       = 3,
	ButtonPress      = 4,
	ButtonRelease    = 5,
	Motion           = 6,
	Enter            = 7,
	Leave            = 8,
	FocusIn          = 9,
	FocusOut         = 10,
	HierarchyChanged = 11,
	PropertyEvent    = 12,
	RawKeyPress      = 13,
	RawKeyRelease    = 14,
	RawButtonPress   = 15,
	RawButtonRelease = 16,
	RawMotion        = 17,
	TouchBegin       = 18,
	TouchUpdate      = 19,
	TouchEnd         = 20,
	TouchOwnership   = 21,
	RawTouchBegin    = 22,
	RawTouchUpdate   = 23,
	RawTouchEnd      = 24,
	BarrierHit       = 25,
	BarrierLeave     = 26,
	GesturePinchBegin  = 27,
	GesturePinchUpdate = 28,
	GesturePinchEnd    = 29,
	GestureSwipeBegin  = 30,
	GestureSwipeUpdate = 31,
	GestureSwipeEnd    = 32,
}

---@enum x11.xi2.Device
xi2.Device = {
	All       = 0,
	AllMaster = 1,
}

return xi2
