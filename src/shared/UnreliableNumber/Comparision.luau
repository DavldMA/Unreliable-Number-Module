local Comparision = {}


function Comparision.isEquals(self, other): boolean
	return self:compare(other) == 0
end

function Comparision.isGreaterOrEquals(self, other): boolean
	return self:compare(other) >= 0
end

function Comparision.isLesserOrEquals(self, other): boolean
	return self:compare(other) <= 0
end

function Comparision.isGreater(self, other): boolean
	return self:compare(other) > 0
end

function Comparision.isLesser(self, other): boolean
	return self:compare(other) < 0
end

function Comparision.compare(self, other): number
	if self.sign ~= other.sign then
		return self.sign - other.sign
	end

	if self.trailingZeros ~= other.trailingZeros then
		return (self.trailingZeros - other.trailingZeros) * self.sign
	end

	if #self.integer ~= #other.integer then
		return (#self.integer - #other.integer) * self.sign
	end

	if self.integer ~= other.integer then
		if self.integer > other.integer then
			return 1 * self.sign
		else
			return -1 * self.sign
		end
	end

	if self.decimal ~= other.decimal then
		if self.decimal > other.decimal then
			return 1 * self.sign
		else
			return -1 * self.sign
		end
	end

	return 0
end

function Comparision.isZero(self): boolean
	return tonumber(self.integer) == 0 and (self.decimal == "" or tonumber(self.decimal) == 0)
end

return Comparision
