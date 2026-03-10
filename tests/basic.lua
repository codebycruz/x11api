local test = require("lpm-test")

local x11 = require("x11api")

local function setFullscreen(display, window, enable)
	local root = x11.defaultRootWindow(display)
	local ev = x11.Event()
	ev.type = x11.EventType.ClientMessage
	ev.xclient.window = window
	ev.xclient.message_type = x11.internAtom(display, "_NET_WM_STATE", x11.False)
	ev.xclient.format = 32
	ev.xclient.data.l[0] = enable and 1 or 0
	ev.xclient.data.l[1] = x11.internAtom(display, "_NET_WM_STATE_FULLSCREEN", x11.False)
	ev.xclient.data.l[2] = 0
	local mask = bit.bor(x11.EventMaskBits.SubstructureNotify, x11.EventMaskBits.SubstructureRedirect)
	x11.sendEvent(display, root, x11.False, mask, ev)
end

-- Subscribe to StructureNotify, map the window, and drain events until MapNotify arrives.
-- This ensures the window is actually viewable before proceeding, on any display server.
local function mapWindowAndWait(display, window)
	x11.selectInput(display, window, x11.EventMaskBits.StructureNotify)
	x11.mapWindow(display, window)
	x11.flush(display)

	local event = x11.Event()
	repeat
		x11.nextEvent(display, event)
	until event.type == x11.EventType.MapNotify
end

test.it("should be able to receive an event from itself", function()
	local display = x11.openDisplay(nil)
	test.notEqual(display, nil) ---@cast display -nil

	local root = x11.defaultRootWindow(display)
	local window = x11.createSimpleWindow(display, root, 10, 10, 100, 100, 1, 0, 0)

	-- Subscribe to receive inputs
	x11.selectInput(display, window, x11.EventMaskBits.Exposure)
	x11.mapWindow(display, window)
	x11.flush(display)


	local eventToSend = x11.Event()
	eventToSend.type = x11.EventType.Expose

	x11.sendEvent(display, window, x11.False, x11.EventMaskBits.Exposure, eventToSend)

	-- Test peek
	do
		local eventReceived = x11.Event()
		x11.peekEvent(display, eventReceived)

		test.equal(eventReceived.type, x11.EventType.Expose)
	end

	-- First event from mapping
	do
		local eventReceived = x11.Event()
		x11.nextEvent(display, eventReceived)

		test.equal(eventReceived.type, x11.EventType.Expose)
	end

	-- Second event from sending artificial event
	do
		local eventReceived = x11.Event()
		x11.nextEvent(display, eventReceived)

		test.equal(eventReceived.type, x11.EventType.Expose)
	end

	-- Now shouldn't have anything left
	do
		local eventReceived = x11.Event()
		local pending = x11.pending(display)
		test.equal(pending, 0)
	end
end)

test.it("should be able to receive a key event from itself", function()
	local display = x11.openDisplay(nil)
	test.notEqual(display, nil) ---@cast display -nil

	local root = x11.defaultRootWindow(display)
	local window = x11.createSimpleWindow(display, root, 10, 10, 100, 100, 1, 0, 0)

	local mask = bit.bor(x11.EventMaskBits.KeyPress, x11.EventMaskBits.KeyRelease)
	x11.selectInput(display, window, mask)
	x11.mapWindow(display, window)
	x11.flush(display)

	-- keycode 38 = 'a' on standard layouts
	local keycode = 38

	local keyPress = x11.Event()
	keyPress.type = x11.EventType.KeyPress
	keyPress.xkey.window = window
	keyPress.xkey.keycode = keycode
	keyPress.xkey.state = 0
	x11.sendEvent(display, window, x11.False, x11.EventMaskBits.KeyPress, keyPress)

	local keyRelease = x11.Event()
	keyRelease.type = x11.EventType.KeyRelease
	keyRelease.xkey.window = window
	keyRelease.xkey.keycode = keycode
	keyRelease.xkey.state = 0
	x11.sendEvent(display, window, x11.False, x11.EventMaskBits.KeyRelease, keyRelease)

	x11.flush(display)

	-- Receive KeyPress
	do
		local event = x11.Event()
		x11.nextEvent(display, event)

		test.equal(event.type, x11.EventType.KeyPress)
		test.equal(event.xkey.keycode, keycode)

		local char, keysym = x11.lookupString(event)
		test.notEqual(keysym, nil)
	end

	-- Receive KeyRelease
	do
		local event = x11.Event()
		x11.nextEvent(display, event)

		test.equal(event.type, x11.EventType.KeyRelease)
		test.equal(event.xkey.keycode, keycode)
	end

	test.equal(x11.pending(display), 0)
end)

test.it("should be able to warp and query the pointer", function()
	local display = x11.openDisplay(nil)
	test.notEqual(display, nil) ---@cast display -nil

	local root = x11.defaultRootWindow(display)
	local window = x11.createSimpleWindow(display, root, 0, 0, 200, 200, 0, 0, 0)
	mapWindowAndWait(display, window)

	-- Warp to (50, 75) relative to the window
	x11.warpPointer(display, 0, window, 0, 0, 0, 0, 50, 75)
	x11.sync(display, x11.False)

	local win_x, win_y = x11.queryPointer(display, window)
	test.equal(win_x, 50)
	test.equal(win_y, 75)
end)

test.it("should be able to grab and ungrab the pointer", function()
	local display = x11.openDisplay(nil)
	test.notEqual(display, nil) ---@cast display -nil

	local root = x11.defaultRootWindow(display)
	local window = x11.createSimpleWindow(display, root, 0, 0, 200, 200, 0, 0, 0)
	mapWindowAndWait(display, window)

	local mouseMask = bit.bor(
		x11.EventMaskBits.ButtonPress,
		x11.EventMaskBits.ButtonRelease,
		x11.EventMaskBits.PointerMotion
	)

	local status = x11.grabPointer(
		display, window, x11.False,
		mouseMask,
		x11.GrabMode.Async, x11.GrabMode.Async,
		window, 0, 0
	)
	test.equal(status, x11.GrabStatus.Success)

	x11.ungrabPointer(display, 0)
	x11.flush(display)
end)

test.it("should be able to set and fetch the window title", function()
	local display = x11.openDisplay(nil)
	test.notEqual(display, nil) ---@cast display -nil

	local root = x11.defaultRootWindow(display)
	local window = x11.createSimpleWindow(display, root, 0, 0, 100, 100, 0, 0, 0)

	x11.storeName(display, window, "hello x11api")
	x11.flush(display)

	local name = x11.fetchName(display, window)
	test.equal(name, "hello x11api")
end)

test.it("should be able to receive focus events from itself", function()
	local display = x11.openDisplay(nil)
	test.notEqual(display, nil) ---@cast display -nil

	local root = x11.defaultRootWindow(display)
	local window = x11.createSimpleWindow(display, root, 0, 0, 100, 100, 0, 0, 0)
	x11.selectInput(display, window, x11.EventMaskBits.FocusChange)
	x11.mapWindow(display, window)
	x11.flush(display)

	local focusIn = x11.Event()
	focusIn.type = x11.EventType.FocusIn
	x11.sendEvent(display, window, x11.False, x11.EventMaskBits.FocusChange, focusIn)

	local focusOut = x11.Event()
	focusOut.type = x11.EventType.FocusOut
	x11.sendEvent(display, window, x11.False, x11.EventMaskBits.FocusChange, focusOut)

	x11.flush(display)

	local e = x11.Event()
	x11.nextEvent(display, e)
	test.equal(e.type, x11.EventType.FocusIn)

	x11.nextEvent(display, e)
	test.equal(e.type, x11.EventType.FocusOut)

	test.equal(x11.pending(display), 0)
end)

test.it("should be able to request fullscreen without error", function()
	local display = x11.openDisplay(nil)
	test.notEqual(display, nil) ---@cast display -nil

	local root = x11.defaultRootWindow(display)
	local window = x11.createSimpleWindow(display, root, 0, 0, 200, 200, 0, 0, 0)
	mapWindowAndWait(display, window)

	setFullscreen(display, window, true)
	x11.flush(display)

	setFullscreen(display, window, false)
	x11.flush(display)
end)

test.it("should be able to grab and ungrab the keyboard", function()
	local display = x11.openDisplay(nil)
	test.notEqual(display, nil) ---@cast display -nil

	local root = x11.defaultRootWindow(display)
	local window = x11.createSimpleWindow(display, root, 0, 0, 200, 200, 0, 0, 0)
	mapWindowAndWait(display, window)

	local status = x11.grabKeyboard(
		display, window, x11.False,
		x11.GrabMode.Async, x11.GrabMode.Async, 0
	)
	test.equal(status, x11.GrabStatus.Success)

	x11.ungrabKeyboard(display, 0)
	x11.flush(display)
end)
