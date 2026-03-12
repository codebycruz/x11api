local x11  = require("x11api")
local xi2  = require("x11api.xi2")

local display = x11.openDisplay(nil)
assert(display, "Failed to open display")

local root   = x11.defaultRootWindow(display)
local window = x11.createSimpleWindow(display, root, 0, 0, 800, 600, 1, 0, 0)

x11.storeName(display, window, "x11api example")
x11.setWMProtocols(display, window, { "WM_DELETE_WINDOW" })

local eventMask = bit.bor(
	x11.EventMaskBits.KeyPress,
	x11.EventMaskBits.KeyRelease,
	x11.EventMaskBits.StructureNotify
)
x11.selectInput(display, window, eventMask)

-- Subscribe to XI RawMotion on root so we get raw deltas regardless of grabs
xi2.selectEvents(display, root, xi2.Device.All, { xi2.EventType.RawMotion })

x11.mapWindow(display, window)
x11.flush(display)

-- Keysym constants
local XK_g      = 0x0067
local XK_l      = 0x006C
local XK_Escape = 0xFF1B

-- Window dimensions (updated on ConfigureNotify)
local winW, winH = 800, 600

-- Create a 1x1 blank pixmap cursor to hide the pointer
local function createBlankCursor()
	local pixmap = x11.createPixmap(display, window, 1, 1, 1)
	local color  = x11.Color()
	local cursor = x11.createPixmapCursor(display, pixmap, pixmap, color, color, 0, 0)
	x11.freePixmap(display, pixmap)
	return cursor
end

local blankCursor = createBlankCursor()

-- Read XI valuator axis values from a raw event.
-- Returns a table keyed by axis index (0 = X, 1 = Y).
local function readValuators(raw)
	local vals = {}
	local vi   = 0
	for axis = 0, raw.valuators.mask_len * 8 - 1 do
		local byte   = math.floor(axis / 8)
		local bitpos = axis % 8
		if bit.band(raw.valuators.mask[byte], bit.lshift(1, bitpos)) ~= 0 then
			vals[axis] = raw.valuators.values[vi]
			vi = vi + 1
		end
	end
	return vals
end

-- ── cursor lock (confine only) ──────────────────────────────────────────────

local cursorLocked = false

local function lockCursor()
	local status = x11.grabPointer(
		display, window,
		x11.False, 0,
		x11.GrabMode.Async, x11.GrabMode.Async,
		window, 0, 0
	)
	if status == x11.GrabStatus.Success then
		cursorLocked = true
		x11.storeName(display, window, "x11api example [LOCKED]")
		print("Cursor locked to window")
	else
		print("Failed to grab pointer, status:", status)
	end
end

local function unlockCursor()
	x11.ungrabPointer(display, 0)
	cursorLocked = false
	x11.storeName(display, window, "x11api example")
	print("Cursor unlocked")
end

-- ── game mode (hidden + centered + raw movement) ────────────────────────────

local gameModeOn = false

local function enableGameMode()
	local status = x11.grabPointer(
		display, window,
		x11.False, 0,
		x11.GrabMode.Async, x11.GrabMode.Async,
		window, blankCursor, 0
	)
	if status ~= x11.GrabStatus.Success then
		print("Failed to grab pointer for game mode, status:", status)
		return
	end
	gameModeOn = true
	-- Center the pointer in the window
	x11.warpPointer(display, 0, window, 0, 0, 0, 0, math.floor(winW / 2), math.floor(winH / 2))
	x11.storeName(display, window, "x11api example [GAME MODE]")
	print("Game mode on — Escape to exit")
end

local function disableGameMode()
	x11.ungrabPointer(display, 0)
	gameModeOn = false
	x11.storeName(display, window, "x11api example")
	print("Game mode off")
end

-- ── event loop ──────────────────────────────────────────────────────────────

print("G = game mode (hidden cursor + raw movement), L = lock cursor, Escape = quit")

local event  = x11.Event()
local running = true

while running do
	x11.nextEvent(display, event)

	local t = event.type

	if t == x11.EventType.ClientMessage then
		running = false

	elseif t == x11.EventType.ConfigureNotify then
		winW = event.xconfigure.width
		winH = event.xconfigure.height

	elseif t == x11.EventType.KeyPress then
		local char, keysym = x11.lookupString(event)

		if keysym == XK_Escape then
			running = false
		elseif keysym == XK_g then
			if gameModeOn then disableGameMode() else enableGameMode() end
		elseif keysym == XK_l then
			if cursorLocked then unlockCursor() else lockCursor() end
		elseif char ~= "" then
			print("Key:", char, string.format("(0x%X)", keysym))
		end

	elseif t == x11.EventType.GenericEvent then
		if x11.getEventData(display, event.xcookie) then
			if event.xcookie.evtype == xi2.EventType.RawMotion then
				local raw  = xi2.castRawEvent(event.xcookie)
				local vals = readValuators(raw)
				local dx   = vals[0] or 0
				local dy   = vals[1] or 0

				if gameModeOn then
					-- Re-center so the pointer never reaches the edge
					x11.warpPointer(display, 0, window, 0, 0, 0, 0, math.floor(winW / 2), math.floor(winH / 2))
					print(string.format("raw delta  dx=%.2f  dy=%.2f", dx, dy))
				end
			end
			x11.freeEventData(display, event.xcookie)
		end
	end
end

-- Cleanup
if gameModeOn  then disableGameMode() end
if cursorLocked then unlockCursor()   end

x11.freeCursor(display, blankCursor)
x11.destroyWindow(display, window)
x11.closeDisplay(display)
