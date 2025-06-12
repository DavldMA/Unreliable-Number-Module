local Config = require(script.Parent.Config)
local Debugger = {}

local balls = {
	Error    	= "🔴",
	Success  	= "🟢",
	Tracing  	= "🔵",
	Warning		= "🟡",
	Black 		= "⚫",  
	Debug		= "⚪",
	Purple   	= "🟣",
	Orange   	= "🟠"
}

local mt = {
	__index = function(self, key)
		local symbol = balls[key]
		if symbol then
			return function(self)
				if Config.debug then
					print("[" .. balls[key] .. " " .. key .. " | UnreliableNumber]: " .. self.message)
				end
			end
		end
		return nil
	end
}

local function new(message)
	return setmetatable({ message = message }, mt)
end

setmetatable(Debugger, { __call = function(_, message) return new(message) end })

return Debugger
