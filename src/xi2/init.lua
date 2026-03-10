local ffi = require("ffi")

ffi.cdef([[#embed "xi2/ffi/ffidefs.h"]])

---@class x11.xi2: x11.xi2.Enums
local xi2 = {}

local enums = require("x11api.xi2.ffi.enums")
for k, v in pairs(enums) do
	xi2[k] = v
end

---@class x11.xi2.Fns
---@field XISelectEvents fun(display: x11.ffi.Display, window: number, masks: ffi.cdata*, num_masks: number): number
local C = ffi.load("libXi.so.6")

---@param display x11.ffi.Display
---@param window number
---@param deviceid x11.xi2.Device|number
---@param evtypes x11.xi2.EventType[] List of XI event types (e.g. xi2.EventType.RawMotion)
function xi2.selectEvents(display, window, deviceid, evtypes)
	-- Build a bitmask large enough to cover all evtype values
	local max_bit = 0
	for _, ev in ipairs(evtypes) do
		if ev > max_bit then max_bit = ev end
	end
	local mask_len = math.floor(max_bit / 8) + 1
	local mask = ffi.new("unsigned char[?]", mask_len)
	for _, ev in ipairs(evtypes) do
		local byte   = math.floor(ev / 8)
		local bitpos = ev % 8
		mask[byte] = bit.bor(mask[byte], bit.lshift(1, bitpos))
	end

	local ev_mask       = ffi.new("XIEventMask[1]")
	ev_mask[0].deviceid = deviceid
	ev_mask[0].mask     = mask
	ev_mask[0].mask_len = mask_len

	return C.XISelectEvents(display, window, ev_mask, 1)
end

---@param event x11.ffi.GenericEventCookie
---@return x11.xi2.ffi.RawEvent
function xi2.castRawEvent(event)
	return ffi.cast("XIRawEvent*", event.data)
end

return xi2
