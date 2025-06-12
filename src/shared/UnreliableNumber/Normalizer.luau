local Config = require(script.Parent.Config)

local Normalizer = {}

local function roundString(numStr, mode)
	assert(type(numStr) == "string", "roundString: numStr must be a string")
	mode = mode:lower()

	if mode == "floor" or mode == "down" then
		return numStr

	elseif mode == "ceil" or mode == "up" then
		local digits = {}
		for i = 1, #numStr do
			digits[i] = tonumber(numStr:sub(i, i))
		end
		local carry = 1
		for i = #digits, 1, -1 do
			local v = digits[i] + carry
			if v >= 10 then
				digits[i] = v - 10
				carry = 1
			else
				digits[i] = v
				carry = 0
				break
			end
		end
		if carry == 1 then
			table.insert(digits, 1, 1)
		end
		return table.concat(digits)

	elseif mode == "nearest" or mode == "round" then
		local last = tonumber(numStr:sub(-1))
		if last >= 5 then
			return roundString(numStr, "ceil")
		else
			return numStr
		end

	else
		error("roundString: unsupported rounding mode '" .. tostring(mode) .. "'")
	end
end

function Normalizer.removeDecimals(self)
	self.decimal = ""
	return self
end

function Normalizer.shiftLeft(self, n)
	local full = self.integer .. self.decimal

	full = full .. string.rep("0", n)

	local newDecLen = #self.decimal + n

	if newDecLen == 0 then
		self.integer = full
		self.decimal = ""
	else
		self.integer = full:sub(1, #full - newDecLen)
		self.decimal = full:sub(-newDecLen)
	end

	self.trailingZeros = self.trailingZeros + n
	return self
end


function Normalizer.shiftRight(self, n)
	self.trailingZeros = self.trailingZeros - n
	self = Normalizer.normalize(self)
end


function Normalizer.normalize(self)
	if #self.integer > Config.significantDigits then
		local extra = #self.integer - Config.significantDigits
		self.integer = self.integer:sub(1, Config.significantDigits)
		self.trailingZeros = self.trailingZeros + extra
	end

	local available = Config.significantDigits - #self.integer
	if available > 0 then
		local zerosToAppend = math.min(available, self.trailingZeros)
		self.integer = self.integer .. string.rep("0", zerosToAppend)
		self.trailingZeros = self.trailingZeros - zerosToAppend
	end

	if #self.decimal > Config.significantDecimals then
		local full      = self.decimal
		local keep      = full:sub(1, Config.significantDecimals)
		local nextDigit = full:sub(Config.significantDecimals+1, Config.significantDecimals+1)
		local rounded   = roundString(keep .. nextDigit, Config.roundingMode)
		self.decimal = rounded:sub(1, Config.significantDecimals)
	end


	self.integer = tostring(tonumber(self.integer))

	return self  
end

return Normalizer
