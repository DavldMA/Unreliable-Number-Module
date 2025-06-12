local PrivateFunctions = {}


function PrivateFunctions.validateInputs(sign: number, integerPart: string, trailingZeros: number, decimalPart: string)
	if type(sign) ~= "number" or (sign ~= 1 and sign ~= -1) then
		error("Invalid sign; use 1 (positive) or -1 (negative)")
	end
	if type(integerPart) ~= "string" or not integerPart:match("^%d+$") then
		error("Integer part must be a string containing digits.")
	end
	if type(trailingZeros) ~= "number" or trailingZeros < 0 then
		error("Trailing zeros must be a non-negative number.")
	end
	if type(decimalPart) ~= "string" or not decimalPart:match("^%d*$") then
		error("Decimal part must be a string containing digits (or empty).")
	end
end

function PrivateFunctions.canUseNative(a, b, opType)
	local n1, n2 = a:toNumber(), b:toNumber()
	local MAX_SAFE, MIN_SAFE = 2^53 - 1, -(2^53 - 1)
	
	if (type(n1) == "string" or type(n2) == "string") or (n1 > MAX_SAFE or n1 < MIN_SAFE or n2 > MAX_SAFE or n2 < MIN_SAFE) then
		return false
	end

	if opType == "+" then
		local r = n1 + n2
		if r > MAX_SAFE or r < MIN_SAFE then
			return false
		end
	elseif opType == "-" then
		local r = n1 - n2
		if r > MAX_SAFE or r < MIN_SAFE then
			return false
		end
	elseif opType == "/" then
		local r = n1 / n2
		if r > MAX_SAFE or r < MIN_SAFE then
			return false
		end
	elseif opType == "*" then
		local r = n1 * n2
		if r > MAX_SAFE or r < MIN_SAFE then
			return false
		end
	else
		return false
	end

	return true
end

function PrivateFunctions.isInSignificantDigits(a, b)
	local sig1 = a.trailingZeros
	local sig2 = #b.integer + b.trailingZeros
	return sig1 > sig2
end


return PrivateFunctions
