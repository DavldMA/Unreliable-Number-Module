local Config = require(script.Parent.Config)
local ISU = require(script.Parent.ISU)
local Normalizer = require(script.Parent.Normalizer)
local PrivateFunctions = require(script.Parent.PrivateFunctions)
--local printd = require(script.Parent.Debugger)


local Utils = {}

function Utils.new(sign: number, integerPart: string, trailingZeros: number, decimalPart: string)
	
	PrivateFunctions.validateInputs(sign, integerPart, trailingZeros, decimalPart or "")
	local self = setmetatable({}, Utils)
	
	self.sign = sign
	self.decimal = decimalPart or ""
	self.integer = integerPart
	self.trailingZeros = trailingZeros
	
	if Config.autoNormalize then
		Normalizer.normalize(self)
	end
	
	return self
end

function Utils.newFromNumber(num: number)
	if type(num) ~= "number" then 
		error("Expected a number") 
	end
	local sign = num < 0 and -1 or 1
	num = math.abs(num)
	local decimalPart = tostring(num):match("%.(%d+)") or ""
	local integerPart = tostring(math.floor(num))
	return Utils.new(sign, integerPart, 0, decimalPart)
end

function Utils.newFromString(str: string)
	if type(str) ~= "string" then
		error("Input must be a string")
	end

	local sign = 1
	if str:sub(1,1) == "-" then
		sign = -1
		str = str:sub(2)
	end

	-- Pattern explanation:
	--   (%d+) : capture one or more digits for the integer part.
	--   %.?(%d*) : optionally capture the decimal part after a dot.
	--   _?(%d*) : optionally capture trailing zeros after an underscore.
	local integerPart, decimalPart, exponentPart = str:match("^(%d+)%.*(%d*)_*(%d*)$")
	if not integerPart then
		error("Malformed string representation")
	end
	return Utils.new(sign, integerPart, tonumber(exponentPart) or 0, decimalPart or "")
end

function Utils.newFromSuffix(str: string)
	local suffixes = ISU.suffixes
	local numPart, suffixPart = str:match("^([%d%.%-]+)(%a*)$")
	suffixPart = string.upper(suffixPart)
	if not numPart then
		warn("Invalid format: " .. tostring(str))
		return nil
	end

	local num = tonumber(numPart)
	if not num then
		warn("Invalid number: " .. tostring(numPart))
		return nil
	end

	local suffixIndex = table.find(suffixes, suffixPart)
	if suffixIndex then
		return Utils.new(1, tostring(num), 3*suffixIndex, "")
	end

	return Utils.newFromNumber(num)
end

function Utils.clone(self)
	return Utils.new(self.sign, self.integer, self.trailingZeros, self.decimal)
end


return Utils