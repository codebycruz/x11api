---@class x11.Enums
local x11 = {}

---@enum x11.EventType
x11.EventType = {
	None = 0,
	ClientMessage = 33,
	Expose = 12,
	KeyPress = 2,
	KeyRelease = 3,
	ButtonPress = 4,
	ButtonRelease = 5,
	MotionNotify = 6,
	UnmapNotify = 18,
	MapNotify = 19,
	ConfigureNotify = 22,
	DestroyNotify = 17,
	CreateNotify = 16,
}

x11.False = 0
x11.True = 1

---@enum x11.EventMaskBits
x11.EventMaskBits = {
	KeyPress = 0x00000001,
	KeyRelease = 0x00000002,
	ButtonPress = 0x00000004,
	ButtonRelease = 0x00000008,
	PointerMotion = 0x00000040,
	Exposure = 0x00008000,
	StructureNotify = 0x00020000,
	SubstructureNotify = 0x00080000,
}

---@enum x11.ModifierMaskBits
x11.ModifierMaskBits = {
	Shift = 0x0001,
	Lock = 0x0002,
	Control = 0x0004,
	Mod1 = 0x0008, -- Alt
	Mod2 = 0x0010, -- NumLock
	Mod3 = 0x0020,
	Mod4 = 0x0040, -- Super/Win
	Mod5 = 0x0080,
}

---@enum x11.Icon
x11.Icon = {
	Arrow = 2,
	BasedArrowDown = 4,
	BasedArrowUp = 6,
	Boat = 8,
	Bogosity = 10,
	BottomLeftCorner = 12,
	BottomRightCorner = 14,
	BottomSide = 16,
	BottomTee = 18,
	BoxSpiral = 20,
	CenterPtr = 22,
	Circle = 24,
	Clock = 26,
	CoffeeMug = 28,
	Cross = 30,
	CrossReverse = 32,
	Crosshair = 34,
	DiamondCross = 36,
	Dot = 38,
	Dotbox = 40,
	DoubleArrow = 42,
	DraftLarge = 44,
	DraftSmall = 46,
	DrapedBox = 48,
	Exchange = 50,
	Fleur = 52,
	Gobbler = 54,
	Gumby = 56,
	Hand1 = 58,
	Hand2 = 60,
	Heart = 62,
	Icon = 64,
	IronCross = 66,
	LeftPtr = 68,
	LeftSide = 70,
	LeftTee = 72,
	Leftbutton = 74,
	LlAngle = 76,
	LrAngle = 78,
	Man = 80,
	Middlebutton = 82,
	Mouse = 84,
	Pencil = 86,
	Pirate = 88,
	Plus = 90,
	QuestionArrow = 92,
	RightPtr = 94,
	RightSide = 96,
	RightTee = 98,
	Rightbutton = 100,
	RtlLogo = 102,
	Sailboat = 104,
	SbDownArrow = 106,
	SbHDoubleArrow = 108,
	SbLeftArrow = 110,
	SbRightArrow = 112,
	SbUpArrow = 114,
	SbVDoubleArrow = 116,
	Shuttle = 118,
	Sizing = 120,
	Spider = 122,
	Spraycan = 124,
	Star = 126,
	Target = 128,
	Tcross = 130,
	TopLeftArrow = 132,
	TopLeftCorner = 134,
	TopRightCorner = 136,
	TopSide = 138,
	TopTee = 140,
	Trek = 142,
	UlAngle = 144,
	Umbrella = 146,
	UrAngle = 148,
	Watch = 150,
	Xterm = 152,
}

return x11
