local Utils = require(script.Parent.Utils)
local Config = require(script.Parent.Config)
local Normalizer = require(script.Parent.Normalizer)
local PrivateFunctions = require(script.Parent.PrivateFunctions)
local Comparision = require(script.Parent.Comparision)

local Arithmetic = {}

function Arithmetic.add(self, other)
	if PrivateFunctions.isInSignificantDigits(self, other) then
		return self
	end
	if PrivateFunctions.canUseNative(self, other, "+") then
		return Utils.newFromNumber(
			self:toNumber() + other:toNumber()
		)
	end
	
	local a = self:clone()
	local b = other:clone()

	local diff = a.trailingZeros - b.trailingZeros
	if diff > 0 then
		b:shiftLeft(diff)
	elseif diff < 0 then
		a:shiftLeft(-diff)
	end

	local decLen = math.max(#a.decimal, #b.decimal)
	a.decimal = a.decimal .. string.rep("0", decLen - #a.decimal)
	b.decimal = b.decimal .. string.rep("0", decLen - #b.decimal)
	
	local s1 = a.integer .. a.decimal
	local s2 = b.integer .. b.decimal
	
	local maxLen = math.max(#s1, #s2)
	if #s1 < maxLen then
		s1 = string.rep("0", maxLen - #s1) .. s1
	end
	if #s2 < maxLen then
		s2 = string.rep("0", maxLen - #s2) .. s2
	end

	local carry = 0
	local result = ""
	for i = maxLen, 1, -1 do
		local sum = tonumber(s1:sub(i,i)) + tonumber(s2:sub(i,i)) + carry
		carry = math.floor(sum / 10)
		result = tostring(sum % 10) .. result
	end
	if carry > 0 then
		result = tostring(carry) .. result
	end

	local intPart = result:sub(1, #result - decLen)
	local decPart = result:sub(-decLen)
	local newNum = Utils.new(self.sign, intPart, a.trailingZeros, decPart)

	if Config.autoNormalize then
		Normalizer.normalize(newNum)
	end

	return newNum
end

function Arithmetic.subtract(self, other)
	if PrivateFunctions.isInSignificantDigits(self, other) then
		return self
	end
	if PrivateFunctions.canUseNative(self, other, "-") then
		return Utils.newFromNumber(
			self:toNumber() - other:toNumber()
		)
	end

	local a = self:clone()
	local b = other:clone()

	if a.sign ~= b.sign then
		b.sign = -b.sign
		return Arithmetic.add(a, b)
	end

	local resultSign = a.sign
	if Comparision.compare(a, b) < 0 then
		resultSign = -resultSign
		a, b = b, a
	end

	local diff = a.trailingZeros - b.trailingZeros
	if diff > 0 then
		b:shiftLeft(diff)
	elseif diff < 0 then
		a:shiftLeft(-diff)
	end

	local decLen = math.max(#a.decimal, #b.decimal)
	a.decimal = a.decimal .. string.rep("0", decLen - #a.decimal)
	b.decimal = b.decimal .. string.rep("0", decLen - #b.decimal)

	local s1 = a.integer .. a.decimal
	local s2 = b.integer .. b.decimal
	local maxLen = math.max(#s1, #s2)
	s1 = string.rep("0", maxLen - #s1) .. s1
	s2 = string.rep("0", maxLen - #s2) .. s2

	local borrow = 0
	local result = ""
	for i = maxLen, 1, -1 do
		local diffDigit = tonumber(s1:sub(i,i)) - tonumber(s2:sub(i,i)) - borrow
		if diffDigit < 0 then
			diffDigit = diffDigit + 10
			borrow = 1
		else
			borrow = 0
		end
		result = tostring(diffDigit) .. result
	end

	local intPart = result:sub(1, #result - decLen)
	local decPart = result:sub(-decLen)
	local newNum = Utils.new(resultSign, intPart, a.trailingZeros, decPart)

	if Config.autoNormalize then
		Normalizer.normalize(newNum)
	end
	return newNum
end




function Arithmetic.multiply(self, other)
	if PrivateFunctions.isInSignificantDigits(self, other) then
		return self
	end
	if PrivateFunctions.canUseNative(self, other, "*") then
		return Utils.newFromNumber(
			self:toNumber() * other:toNumber()
		)
	end

	local a = self:clone()
	local b = other:clone()

	local s1 = a.integer .. a.decimal
	local s2 = b.integer .. b.decimal
	local len1 = #s1
	local len2 = #s2

	local result = {}
	for i = 1, len1 + len2 do
		result[i] = 0
	end

	for i = len1, 1, -1 do
		local d1 = tonumber(s1:sub(i, i))
		for j = len2, 1, -1 do
			local d2 = tonumber(s2:sub(j, j))
			local idx = (len1 - i) + (len2 - j) + 1
			result[idx] = result[idx] + d1 * d2
		end
	end

	for k = 1, #result do
		local carry = math.floor(result[k] / 10)
		result[k] = result[k] % 10
		if carry > 0 then
			result[k + 1] = result[k + 1] + carry
		end
	end

	local raw = ""
	for k = #result, 1, -1 do
		raw = raw .. tostring(result[k])
	end

	local decLen = #a.decimal + #b.decimal
	local intPart = (#raw > decLen) and raw:sub(1, #raw - decLen) or "0"
	local decPart = decLen > 0 and raw:sub(-decLen) or ""
	local totalZeros = a.trailingZeros + b.trailingZeros

	local newNum = Utils.new(a.sign * b.sign, intPart, totalZeros, decPart)
	if Config.autoNormalize then
		Normalizer.normalize(newNum)
	end
	return newNum
end


function Arithmetic.divide(self, other)
	if PrivateFunctions.isInSignificantDigits(self, other) then
		return self
	end
	if PrivateFunctions.canUseNative(self, other, "/") then
		return Utils.newFromNumber(
			self:toNumber() / other:toNumber()
		)
	end
	
	local a = self:clone()
	local b = other:clone()
	
	local sign = a.sign * b.sign
	local decA, decB = #a.decimal, #b.decimal
	local s1 = a.integer .. a.decimal
	local s2 = b.integer .. b.decimal
	local idx, len1 = 1, #s1
	local remainder = ""
	local rawQuotient = ""
	
	while idx <= len1 do
		remainder = (remainder == "" or remainder == "0") and s1:sub(idx,idx) or remainder .. s1:sub(idx,idx)
		remainder = remainder:gsub("^0+", "")
		if remainder == "" then
			remainder = "0"
		end
		idx = idx + 1
		local remBN = Utils.new(1, remainder, 0, "")
		local divBN = Utils.new(1, s2, 0, "")
		local qDigit = 0
		while qDigit < 10 and Comparision.compare(remBN, divBN) >= 0 do
			remBN = Arithmetic.subtract(remBN, divBN)
			qDigit = qDigit + 1
		end
		rawQuotient = rawQuotient .. tostring(qDigit)
		remainder = remBN.integer .. remBN.decimal
	end
	
	local maxDec = decA + decB
	local decCount = 0
	if remainder ~= "0" then
		while decCount < maxDec do
			remainder = remainder .. "0"
			local remBN = Utils.new(1, remainder, 0, "")
			local divBN = Utils.new(1, s2, 0, "")
			local qDigit = 0
			while qDigit < 10 and Comparision.compare(remBN, divBN) >= 0 do
				remBN = Arithmetic.subtract(remBN, divBN)
				qDigit = qDigit + 1
			end
			rawQuotient = rawQuotient .. tostring(qDigit)
			remainder = remBN.integer .. remBN.decimal
			decCount = decCount + 1
		end
	end
	
	rawQuotient = rawQuotient:gsub("^0+", "")
	if rawQuotient == "" then
		rawQuotient = "0"
	end
	local shift = decA - decB
	local intPart, decPart = "", ""
	
	if shift >= 0 then
		if #rawQuotient > shift then
			intPart = rawQuotient:sub(1, #rawQuotient-shift)
			decPart = rawQuotient:sub(-shift)
		else
			intPart = "0"
			decPart = string.rep("0", shift - #rawQuotient) .. rawQuotient
		end
	else
		intPart = rawQuotient .. string.rep("0", -shift)
		decPart = ""
	end
	
	local totalZeros = a.trailingZeros - b.trailingZeros
	local newNum = Utils.new(sign, intPart, totalZeros, decPart)
	if Config.autoNormalize then
		Normalizer.normalize(newNum)
	end
	return newNum
end

return Arithmetic