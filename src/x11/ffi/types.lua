---@class x11.ffi.Display: ffi.cdata*
---@alias x11.ffi.Atom number

---@class x11.ffi.WindowAttributes: ffi.cdata*
---@field x number
---@field y number
---@field width number
---@field height number

---@class x11.ffi.Event: ffi.cdata*
---@field type number
---@field xclient { data: { l: number[] }, display: ffi.cdata*, window: number }
---@field xexpose { window: number }
---@field xany { window: number }
---@field xconfigure { window: number, x: number, y: number, width: number, height: number }
---@field xmotion { window: number, x: number, y: number }
---@field xbutton { x: number, y: number, button: number, state: number }
---@field xkey { window: number, root: number, time: number, x: number, y: number, x_root: number, y_root: number, state: number, keycode: number, same_screen: number }
---@field xcookie x11.ffi.GenericEventCookie

---@class x11.ffi.GenericEventCookie: ffi.cdata*
---@field type number
---@field extension number
---@field evtype number
---@field cookie number
---@field data ffi.cdata*
