--local Utils = require(script.Parent.Utils)
local ISU = require(script.Parent.ISU)

local Serializer = {}

function Serializer.toSuffix(self): string
	local suffixes = ISU.suffixes
	local fullNumber = Serializer.toFullNumber(self)
	local num = tonumber(fullNumber)
	if not num then
		warn("Cannot convert to suffix: invalid number")
		return ""
	end

	local signStr = self.sign < 0 and "-" or ""

	local suffixIndex = 0
	while math.abs(num) >= 1000 and suffixIndex < #suffixes do
		num = num / 1000
		suffixIndex += 1
	end

	local formatted
	if num >= 100 then
		formatted = string.format("%.1f", num)
	elseif num >= 10 then
		formatted = string.format("%.2f", num)
	else
		formatted = string.format("%.0f", num)
	end

	formatted = formatted:gsub("%.0+$", "")
	formatted = formatted:gsub("%.(0+)$", "")


	return signStr .. formatted .. (suffixes[suffixIndex] or "")
end

function Serializer.toFullNumber(self): string
	local str = self.integer
	str = str .. string.rep("0", self.trailingZeros)
	if self.decimal and self.decimal ~= "" then
		str = str .. "." .. self.decimal
	end
	if self.sign < 0 then
		str = "-" .. str
	end
	return str
end

function Serializer.toFullSuffix(self): string
	local suffixes = ISU.names
	local fullNumber = Serializer.toFullNumber(self)
	local num = tonumber(fullNumber)
	if not num then
		warn("Cannot convert to suffix: invalid number")
		return ""
	end

	local signStr = self.sign < 0 and "-" or ""

	local suffixIndex = 0
	while math.abs(num) >= 1000 and suffixIndex < #suffixes do
		num = num / 1000
		suffixIndex += 1
	end

	local formatted
	if num >= 100 then
		formatted = string.format("%.1f", num)
	elseif num >= 10 then
		formatted = string.format("%.2f", num)
	else
		formatted = string.format("%.0f", num)
	end

	formatted = formatted:gsub("%.0+$", "")
	formatted = formatted:gsub("%.(0+)$", "")

	return signStr .. formatted .. " " .. (suffixes[suffixIndex] or "")
end

function Serializer.toString(self): string
	local str = self.integer
	if self.decimal and self.decimal ~= "" then
		str = str .. "." .. self.decimal
	end
	if self.trailingZeros and self.trailingZeros ~= 0 then
		str = str .. "_" .. tostring(self.trailingZeros)
	end
	if self.sign < 0 then
		str = "-" .. str
	end
	return str
end

function Serializer.toNumber(self): number
	local MAX_INT_DIGITS = 19
	local MAX_INT_STR = "9007199254740991"
	local signStr = (self.sign < 0) and "-" or ""

	local fullIntegerStr = self.integer .. string.rep("0", self.trailingZeros)

	local hasDecimal = self.decimal and tonumber(self.decimal) ~= 0

	local function exceedsMaxInt(intStr)
		return #intStr > MAX_INT_DIGITS or 
			(#intStr == MAX_INT_DIGITS and intStr > MAX_INT_STR)
	end

	if not hasDecimal then
		if exceedsMaxInt(fullIntegerStr) then
			return signStr .. fullIntegerStr
		else
			return self.sign * tonumber(fullIntegerStr)
		end
	else
		if exceedsMaxInt(fullIntegerStr) then
			return signStr .. fullIntegerStr .. "." .. self.decimal
		else
			local integerValue = tonumber(self.integer)
			local decimalValue = tonumber("0." .. self.decimal)
			local scaledInteger = integerValue * (10 ^ self.trailingZeros)
			local result = scaledInteger + decimalValue
			return self.sign * result
		end
	end
end

return Serializer
