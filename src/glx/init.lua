local ffi = require("ffi")

ffi.cdef([[#embed "glx/ffi/ffidefs.h"]])

---@class glx: glx.Enums
local glx = {}

local enums = require("x11api.glx.ffi.enums")
for k, v in pairs(enums) do
	glx[k] = v
end

---@class x11.glx.Fns
---@field glXMakeCurrent fun(display: x11.ffi.Display, window: number, context: x11.glx.ffi.Context)
---@field glXMakeContextCurrent fun(display: x11.ffi.Display, window: number, read: number, context: x11.glx.ffi.Context)
---@field glXSwapBuffers fun(display: x11.ffi.Display, window: number)
---@field glXDestroyContext fun(display: x11.ffi.Display, ctx: x11.glx.ffi.Context)
---@field glXGetCurrentContext fun(): x11.glx.ffi.Context?
---@field glXGetCurrentDisplay fun(): x11.ffi.Display?
---@field glXGetCurrentDrawable fun(): number
---@field glXQueryDrawable fun(display: x11.ffi.Display, draw: number, attribute: number): number
---@field glXQueryExtensionsString fun(display: x11.ffi.Display, screen: number): string
---@field glXGetProcAddress fun(procname: string): function
local C = ffi.load("libGL.so.1")

glx.makeCurrent = C.glXMakeCurrent
glx.makeContextCurrent = C.glXMakeContextCurrent
glx.swapBuffers = C.glXSwapBuffers
glx.destroyContext = C.glXDestroyContext
glx.getCurrentContext = C.glXGetCurrentContext
glx.getCurrentDisplay = C.glXGetCurrentDisplay
glx.getCurrentDrawable = C.glXGetCurrentDrawable
glx.getProcAddress = C.glXGetProcAddress

---@param display x11.ffi.Display
---@param draw number
---@param attribute number
function glx.queryDrawable(display, draw, attribute)
	local value = ffi.new("unsigned int[1]")
	C.glXQueryDrawable(display, draw, attribute, value)
	return value[0]
end

---@param display x11.ffi.Display
---@param screen number
---@return string
function glx.queryExtensionsString(display, screen)
	local extStr = C.glXQueryExtensionsString(display, screen)
	if extStr == nil then
		return ""
	end

	return ffi.string(extStr)
end

do
	local types = {
		glXChooseFBConfig = "GLXFBConfig*(*)(XDisplay*, int, const int*, int*)",
		glXCreateContextAttribsARB = "GLXContext(*)(XDisplay*, GLXFBConfig*, GLXContext, int, const int*)",
	}

	---@class x11.glx.FnsExt
	---@field glXChooseFBConfig fun(display: x11.ffi.Display, screen: number, attributes: number[], nelements: ffi.cdata*): x11.glx.ffi.FBConfig?
	---@field glXCreateContextAttribsARB fun(display: x11.ffi.Display, config: x11.glx.ffi.FBConfig, share_context: ffi.cdata*?, direct: number, attrib_list: number[]): ffi.cdata*
	local C = {}
	for name, type in pairs(types) do
		C[name] = ffi.cast(type, glx.getProcAddress(name))
	end

	---@param display x11.ffi.Display
	---@param screen number
	---@param attributes number[]
	---@return x11.glx.ffi.FBConfig?
	glx.chooseFBConfig = function(display, screen, attributes)
		local attribList = ffi.new("int[?]", #attributes + 1, attributes)
		attribList[#attributes] = 0

		local nelements = ffi.new("int[1]")
		local configs = C.glXChooseFBConfig(display, screen, attribList, nelements)

		if configs == nil or nelements[0] == 0 then
			return nil
		end

		return configs[0]
	end

	---@type fun(display: x11.ffi.Display, config: x11.glx.ffi.FBConfig, share_context: ffi.cdata*?, direct: number, attrib_list: number[]): ffi.cdata*
	glx.createContextAttribsARB = function(display, config, share_context, direct, attrib_list)
		local attribList = ffi.new("int[?]", #attrib_list + 1, attrib_list)
		attribList[#attrib_list] = 0

		return C.glXCreateContextAttribsARB(display, config, share_context, direct, attribList)
	end
end


return glx
