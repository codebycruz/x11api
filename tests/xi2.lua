local test = require("lpm-test")

local x11 = require("x11api")
local xi2 = require("x11api.xi2")

test.it("should be able to select XI2 raw events without error", function()
	local display = x11.openDisplay(nil)
	test.notEqual(display, nil) ---@cast display -nil

	local root = x11.defaultRootWindow(display)

	local status = xi2.selectEvents(display, root, xi2.Device.AllMaster, {
		xi2.EventType.RawMotion,
		xi2.EventType.RawButtonPress,
		xi2.EventType.RawButtonRelease,
	})

	-- XISelectEvents returns 0 on success
	test.equal(status, 0)

	x11.flush(display)
end)
