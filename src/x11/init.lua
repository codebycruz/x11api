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
local C = ffi.load("libX11.so.6")

---@class x11
---@field Atom fun(): x11.ffi.Atom
---@field AtomArray fun(count: number): x11.ffi.Atom[]
---@field WindowAttributes fun(): x11.ffi.WindowAttributes
---@field Event fun(): x11.ffi.Event
local x11 = {}

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
