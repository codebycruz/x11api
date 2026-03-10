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
