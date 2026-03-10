local test = require("lpm-test")

local x11 = require("x11api")

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
