local separator = string.sub(package.config, 1, 1)
local outDir = os.getenv("LPM_OUTPUT_DIR")

local function read(p)
	local handle = io.open(p, "r")
	local content = handle:read("*a")
	handle:close()
	return content
end

local files = { "glx" .. separator .. "init.lua", "x11" .. separator .. "init.lua", "xi2" .. separator .. "init.lua" }

local escapes = {
	["\\"] = "\\\\",
	["\""] = "\\\"",
	["\n"] = "\\n",
	["\r"] = "\\r",
	["\t"] = "\\t"
}

for i, fileName in ipairs(files) do
	local content = read(outDir .. separator .. fileName)

	local preprocessed = string.gsub(content, "%[%[#embed \"([^\"]+)\"%]%]", function(filename)
		local content = read(outDir .. separator .. filename)
		return '"' .. (content:gsub("[\\\"\n\r\t]", escapes)) .. '"'
	end)

	local outFile = io.open(outDir .. separator .. fileName, "w")
	outFile:write(preprocessed)
	outFile:close()
end
