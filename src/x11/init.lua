local ffi = require("ffi")

ffi.cdef([[#embed "x11/ffi/ffidefs.h"]])

---@class x11.Fns
---@field XOpenDisplay fun(display_name: string?): x11.ffi.Display?
---@field XCloseDisplay fun(display: x11.ffi.Display): number
---@field XDestroyWindow fun(display: x11.ffi.Display, window: number)
---@field XDefaultRootWindow fun(display: x11.ffi.Display): number
---@field XCreateSimpleWindow fun(display: x11.ffi.Display, parent: number, x: number, y: number, width: number, height: number, border_width: number, border: number, background: number): number
---@field XMapWindow fun(display: x11.ffi.Display, w: number)
---@field XInternAtom fun(display: x11.ffi.Display, atom_name: string, only_if_exists: number): number
---@field XSetWMProtocols fun(display: x11.ffi.Display, window: number, protocols: number[], count: number): number
---@field XNextEvent fun(display: x11.ffi.Display, event_return: x11.ffi.Event)
---@field XPeekEvent fun(display: x11.ffi.Display, event_return: x11.ffi.Event)
---@field XDefaultScreen fun(display: x11.ffi.Display): number
---@field XPending fun(display: x11.ffi.Display): number
---@field XSelectInput fun(display: x11.ffi.Display, w: number, event_mask: number)
---@field XGetWindowAttributes fun(display: x11.ffi.Display, w: number, window_attributes_return: x11.ffi.WindowAttributes): number
---@field XCreateFontCursor fun(display: x11.ffi.Display, shape: number): number
---@field XDefineCursor fun(display: x11.ffi.Display, w: number, cursor: number)
---@field XUndefineCursor fun(display: x11.ffi.Display, w: number)
---@field XFreeCursor fun(display: x11.ffi.Display, cursor: number)
---@field XFlush fun(display: x11.ffi.Display)
---@field XChangeProperty fun(display: x11.ffi.Display, w: number, property: number, type: number, format: number, mode: number, data: string|ffi.cdata*, nelements: number)
---@field XSendEvent fun(display: x11.ffi.Display, w: number, propagate: number, event_mask: number, event_send: x11.ffi.Event): number
---@field XSync fun(display: x11.ffi.Display, discard: number)
---@field XKeycodeToKeysym fun(display: x11.ffi.Display, keycode: number, index: number): number
---@field XLookupString fun(event_struct: x11.ffi.Event, buffer_return: ffi.cdata*, bytes_buffer: number, keysym_return: ffi.cdata*, status_in_out: ffi.cdata*): number
---@field XWarpPointer fun(display: x11.ffi.Display, src_w: number, dest_w: number, src_x: number, src_y: number, src_width: number, src_height: number, dest_x: number, dest_y: number): number
---@field XQueryPointer fun(display: x11.ffi.Display, w: number, root_return: ffi.cdata*, child_return: ffi.cdata*, root_x_return: ffi.cdata*, root_y_return: ffi.cdata*, win_x_return: ffi.cdata*, win_y_return: ffi.cdata*, mask_return: ffi.cdata*): number
---@field XGrabPointer fun(display: x11.ffi.Display, grab_window: number, owner_events: number, event_mask: number, pointer_mode: number, keyboard_mode: number, confine_to: number, cursor: number, time: number): number
---@field XUngrabPointer fun(display: x11.ffi.Display, time: number): number
---@field XGrabKeyboard fun(display: x11.ffi.Display, grab_window: number, owner_events: number, pointer_mode: number, keyboard_mode: number, time: number): number
---@field XUngrabKeyboard fun(display: x11.ffi.Display, time: number): number
---@field XServerVendor fun(display: x11.ffi.Display): ffi.cdata*
---@field XStoreName fun(display: x11.ffi.Display, w: number, window_name: string): number
---@field XFetchName fun(display: x11.ffi.Display, w: number, window_name_return: ffi.cdata*): number
---@field XFree fun(data: ffi.cdata*)
local C = ffi.load("libX11.so.6")

---@class x11: x11.Enums
---@field Atom fun(): x11.ffi.Atom
---@field AtomArray fun(count: number): x11.ffi.Atom[]
---@field WindowAttributes fun(): x11.ffi.WindowAttributes
---@field Event fun(): x11.ffi.Event
---@field KeySym fun(): number[]
local x11 = {}

local enums = require("x11api.x11.ffi.enums")
for k, v in pairs(enums) do
	x11[k] = v
end

---@param ffiName string
local function defType(ffiName)
	local cons = ffi.typeof("X" .. ffiName)
		or error("Failed to find FFI type for Vk" .. ffiName)

	local arrayCons = ffi.typeof("X" .. ffiName .. "[?]")

	x11[ffiName] = cons
	x11[ffiName .. "Array"] = arrayCons
end

defType("Atom")
defType("WindowAttributes")
defType("Event")

x11.KeySym = ffi.typeof("XKeySym[1]")

x11.openDisplay = C.XOpenDisplay
x11.closeDisplay = C.XCloseDisplay
x11.destroyWindow = C.XDestroyWindow
x11.defaultRootWindow = C.XDefaultRootWindow
x11.createSimpleWindow = C.XCreateSimpleWindow
x11.mapWindow = C.XMapWindow
x11.internAtom = C.XInternAtom
x11.nextEvent = C.XNextEvent
x11.peekEvent = C.XPeekEvent
x11.defaultScreen = C.XDefaultScreen
x11.pending = C.XPending
x11.selectInput = C.XSelectInput
x11.createFontCursor = C.XCreateFontCursor
x11.defineCursor = C.XDefineCursor
x11.undefineCursor = C.XUndefineCursor
x11.freeCursor = C.XFreeCursor
x11.flush = C.XFlush
x11.sendEvent = C.XSendEvent
x11.sync = C.XSync
x11.keycodeToKeysym = C.XKeycodeToKeysym
x11.warpPointer = C.XWarpPointer
x11.grabPointer = C.XGrabPointer
x11.ungrabPointer = C.XUngrabPointer
x11.grabKeyboard = C.XGrabKeyboard
x11.ungrabKeyboard = C.XUngrabKeyboard
x11.storeName = C.XStoreName

---@param display x11.ffi.Display
---@param window number
---@return string?
function x11.fetchName(display, window)
	local ptr = ffi.new("char*[1]")
	local status = C.XFetchName(display, window, ptr)
	if status == 0 or ptr[0] == nil then return nil end
	local name = ffi.string(ptr[0])
	C.XFree(ptr[0])
	return name
end


---@param display x11.ffi.Display
---@return string
function x11.serverVendor(display)
	return ffi.string(C.XServerVendor(display))
end

---@param display x11.ffi.Display
---@param window number
---@return number win_x, number win_y, number root_x, number root_y
function x11.queryPointer(display, window)
	local root = ffi.new("XWindow[1]")
	local child = ffi.new("XWindow[1]")
	local root_x = ffi.new("int[1]")
	local root_y = ffi.new("int[1]")
	local win_x = ffi.new("int[1]")
	local win_y = ffi.new("int[1]")
	local mask = ffi.new("unsigned int[1]")
	C.XQueryPointer(display, window, root, child, root_x, root_y, win_x, win_y, mask)
	return win_x[0], win_y[0], root_x[0], root_y[0]
end

---@param event x11.ffi.Event
---@return string char, number keysym
function x11.lookupString(event)
	local buf = ffi.new("char[32]")
	local keysym = x11.KeySym()
	local keyEvent = ffi.cast("XKeyEvent*", event)
	local len = C.XLookupString(keyEvent, buf, 32, keysym, nil)
	return ffi.string(buf, len), keysym[0]
end

---@param display x11.ffi.Display
---@param window number # Window id
---@param protocols string[]
function x11.setWMProtocols(display, window, protocols)
	local atoms = x11.AtomArray(#protocols)
	for i = 1, #protocols do
		atoms[i - 1] = C.XInternAtom(display, protocols[i], 0)
	end

	C.XSetWMProtocols(display, window, atoms, #protocols)
end

---@param display x11.ffi.Display
---@param window number # Window id
function x11.getWindowAttributes(display, window)
	local attrs = x11.WindowAttributes()

	local status = C.XGetWindowAttributes(display, window, attrs)
	if status == 0 then
		return nil
	end

	return attrs
end

---@param display x11.ffi.Display
---@param window number
---@param property string
---@param ty string
---@param format number
---@param mode number
---@param data ffi.cdata*
---@param nelements number
function x11.changeProperty(display, window, property, ty, format, mode, data, nelements)
	local propAtom = C.XInternAtom(display, property, 0)
	local typeAtom = C.XInternAtom(display, ty, 0)

	C.XChangeProperty(display, window, propAtom, typeAtom, format, mode, data, nelements)
end

return x11
