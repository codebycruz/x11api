---@class x11.xi2.Enums
local xi2 = {}

---@enum x11.xi2.EventType
xi2.EventType = {
	RawButtonPress   = 15,
	RawButtonRelease = 16,
	RawMotion        = 17,
}

---@enum x11.xi2.Device
xi2.Device = {
	All       = 0,
	AllMaster = 1,
}

return xi2
