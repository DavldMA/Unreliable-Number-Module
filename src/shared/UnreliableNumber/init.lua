--[[
UnreliableNumber (Module)

    A loosely formatted numeric representation preserving input precision and layout.
    Useful when formatting fidelity matters more than arithmetic accuracy, such as for
    display rendering or non-critical number manipulation. Its also useful for infinite
    scalable numbers, such as in simulation games, where 1000T doesnt need to know if the
    player has 1000 trillion or 1000 trillion and 1, as long as it looks like 1000T, of
    course, this comes with the downside of the player being able to buy infinitely of a
    resource that costs 1 to 9, but this is a tradeoff for the sake of performance
    and simplicity, since that resource that costs 1 to 9 is not really valuable for that
    player, and even so, with 1000T he would be able to buy a LOT of that resource,
    so it is not really a problem, only is a problem in theory, but not in practice in my
    honest opinion.

------------------------------------------------------

FIELDS:

    UnreliableNumber.sign           [number]   -- 1 (positive) or -1 (negative)
    UnreliableNumber.integer        [string]   -- Whole number part (unsigned string)
    UnreliableNumber.trailingZeros  [number]   -- Count of trailing zeroes in integer section
    UnreliableNumber.decimal        [string]   -- Decimal part (may retain trailing zeros for fidelity)

------------------------------------------------------

CONSTRUCTORS:

    UnreliableNumber.new(sign: number, integer: string, trailingZeros: number, decimal: string) --> [UnreliableNumber]
        -- Constructs a new instance directly with field values.

    UnreliableNumber.fromNumber(num: number) --> [UnreliableNumber]
        -- Constructs from a Lua number, capturing its approximate decimal form.
        -- WARNING: Not suitable for high precision or accurate values.

    UnreliableNumber.fromString(str: string) --> [UnreliableNumber]
        -- Constructs from a numeric string, preserving exact formatting.
        -- Retains leading/trailing zeros, decimal precision, etc.

    UnreliableNumber.fromSuffix(num: string) --> [UnreliableNumber]
        -- Constructs from a string with suffix notation (e.g., "1K", "2.5M").
        -- Parses and retains formatting, converting to UnreliableNumber format.

    UnreliableNumber:clone() --> [UnreliableNumber]
        -- Returns a deep copy of this instance.

------------------------------------------------------

METHODS:

    UnreliableNumber:add(other: UnreliableNumber | number) --> [UnreliableNumber]
        -- Adds another UnreliableNumber or Lua number, returning a new instance.
        -- Preserves formatting and precision.

    UnreliableNumber:subtract(other: UnreliableNumber | number) --> [UnreliableNumber]
        -- Subtracts another UnreliableNumber or Lua number, returning a new instance.
        -- Preserves formatting and precision.

    UnreliableNumber:multiply(other: UnreliableNumber | number) --> [UnreliableNumber]
        -- Multiplies by another UnreliableNumber or Lua number, returning a new instance.
        -- Preserves formatting and precision.

    UnreliableNumber:divide(other: UnreliableNumber | number) --> [UnreliableNumber]
        -- Divides by another UnreliableNumber or Lua number, returning a new instance.
        -- Preserves formatting and precision.

    UnreliableNumber:removeDecimals() --> nil
        -- Removes the decimal part, keeping only the integer and trailing zeros.
        -- Alters the number to be a whole number without decimals.

    UnreliableNumber:shiftLeft(n: number) --> nil
        -- Shifts the decimal point left by `n` digits.
        -- Equivalent to dividing by 10^n, altering integer/decimal split.
        -- Preserves formatting but may change precision.
        
    UnreliableNumber:shiftRight(n: number) --> nil
        -- Shifts the decimal point right by `n` digits.
        -- Equivalent to multiplying by 10^n, altering integer/decimal split.
        -- Preserves formatting but may change precision.

    UnreliableNumber:normalize(config?: table) --> nil
        -- Adjusts string representation for visual formatting.
        -- Optional config:
        --   maxDecimalDigits: number?       -- Truncates decimal to max digits
        --   trimLeadingZeros: boolean?      -- Removes unnecessary leading integer zeros
        --   preserveZeros: boolean?         -- Keeps trailing zeros in decimal part

    UnreliableNumber:serialize(raw: boolean?) --> [string | number]
        -- Returns string representation preserving format.
        -- If `raw` is true, converts to Lua number (may lose accuracy).

    UnreliableNumber:isEqual(other: UnreliableNumber) --> [boolean]
        -- Compares if two instances have identical formatting and structure.
        -- Does NOT test numeric equivalence.

    UnreliableNumber:isGreater(other: UnreliableNumber) --> [boolean]
        -- Checks if this instance is greater than another.
        -- Compares based on formatting, not numeric value.
    
    UnreliableNumber:isLesser(other: UnreliableNumber) --> [boolean]
        -- Checks if this instance is lesser than another.
        -- Compares based on formatting, not numeric value.
    
    UnreliableNumber:isGreaterOrEquals(other: UnreliableNumber) --> [boolean]
        -- Checks if this instance is greater than or equal to another.
        -- Compares based on formatting, not numeric value.

    UnreliableNumber:isLesserOrEquals(other: UnreliableNumber) --> [boolean]
        -- Checks if this instance is lesser than or equal to another.
        -- Compares based on formatting, not numeric value.
    
    UnreliableNumber:isZero() --> [boolean]
        -- Checks if this instance represents zero.
        -- Compares based on formatting, not numeric value.

    UnreliableNumber:compare(other: UnreliableNumber) --> [number]
        -- Compares this instance to another, returning -1, 0, or 1.
        -- Based on formatting and structure, not numeric value.

    UnreliableNumber:toFullSuffix() --> [string]
        -- Returns a full suffix representation.

    UnreliableNumber:toFullNumber() --> [string]
        -- Returns the full number as a string, including integer and decimal parts.
        -- Preserves all formatting details, including leading/trailing zeros.

    UnreliableNumber:toSuffix() --> [string]
        -- Returns a formatted string with suffix notation (e.g., "1K", "2.5M").

    UnreliableNumber:toNumber() --> [number]
        -- Converts to Lua number using standard coercion.
        -- WARNING: Use only when high accuracy is not needed.

    UnreliableNumber:toString() --> [string]
        -- Reconstructs and returns the full string form.
        -- Reflects formatting of original input or mutated state.

------------------------------------------------------

OPERATOR OVERLOADS:

    + - * / ^ %    -- Supported, but operations are approximate and unreliable
    == < > <= >=   -- Lexical and formatting-based comparison, not true numeric logic

------------------------------------------------------

USAGE NOTES:

    - Designed for aesthetic and formatting-sensitive uses, not computation
    - Input strings are not heavily validated—ensure correctness manually
    - Not recommended for integration with Roblox data types (Vector3, CFrame, etc.)

------------------------------------------------------

VERSION:

    v1.0.0 - Core Code
    v1.0.1 - Revised the Documentation
	v1.0.2 - Added Tests

--]]




local Arithmetic = require(script.Arithmetic)
local Comparision = require(script.Comparision)
local Config = require(script.Config)
--local ISU = require(script.ISU)
local Normalizer = require(script.Normalizer)
local Serializer = require(script.Serializer)
local Utils = require(script.Utils)
local printd = require(script.Debugger)
local UnreliableNumber = {}


UnreliableNumber.__index = UnreliableNumber

export type UnreliableNumber = {
	sign: number,
	integer: number,
	trailingZeros: number,
	decimal: number,
	add: (self: UnreliableNumber, other: UnreliableNumber) -> UnreliableNumber,
	subtract: (self: UnreliableNumber, other: UnreliableNumber) -> UnreliableNumber,
	multiply: (self: UnreliableNumber, other: UnreliableNumber) -> UnreliableNumber,
	divide: (self: UnreliableNumber, other: UnreliableNumber) -> UnreliableNumber,
	normalize: (self: UnreliableNumber) -> (),
	removeDecimals: (self: UnreliableNumber) -> (),
	shiftLeft: (self: UnreliableNumber, n: number) -> (),
	shiftRight: (self: UnreliableNumber, n: number) -> (),
	clone: (self: UnreliableNumber) -> UnreliableNumber,
	toFullNumber: (self: UnreliableNumber) -> string,
	toString: (self: UnreliableNumber) -> string,
	toSuffix: (self: UnreliableNumber) -> string,
	toFullSuffix: (self: UnreliableNumber) -> string,
	toNumber: (self: UnreliableNumber) -> number,
	isEquals: (self: UnreliableNumber, other: UnreliableNumber) -> boolean,
	isGreater: (self: UnreliableNumber, other: UnreliableNumber) -> boolean,
	isLesser: (self: UnreliableNumber, other: UnreliableNumber) -> boolean,
	isGreaterOrEquals: (self: UnreliableNumber, other: UnreliableNumber) -> boolean,
	isLesserOrEquals: (self: UnreliableNumber, other: UnreliableNumber) -> boolean,
	isZero: (self: UnreliableNumber) -> boolean,
}

local config = {
	significantDigits = 20,       -- Maximum significant digits for the integer part
	significantDecimals = 4,      -- Maximum significant digits for the decimal part
	roundingMode = "nearest",     -- Rounding mode: "ceil", "floor", or "nearest"
	autoNormalize = true,		  -- Auto normalize the number (recommended)
	debug = false,                -- Debug mode for testing, outputs extra information
}



function setup()
	for k, v in pairs(config) do
		Config[k] = v
	end
	printd = printd
	UnreliableNumber.Debugger = printd
	printd("Unreliable Number was loaded succesfully"):Success()
end

-------------------------------
--  Utility and Constructor  --
-------------------------------

--[[
Creates a new <strong>UnreliableNumber</strong> from raw components.<br>
Use when manually constructing numbers with specific formatting, such as custom precision or leading/trailing zero control.<br>
<strong><em>Example:</em></strong>
<code>UnreliableNumber.new(1, "100", 10, "10")</code>
]]
function UnreliableNumber.new(sign: number, integer: string, trailingZeros: number, decimal: string): UnreliableNumber
	printd("Creating new UnreliableNumber"):Tracing()
	local self = Utils.new(sign, integer, trailingZeros, decimal)
	setmetatable(self, UnreliableNumber)
	return self
end

--[[
Creates a new <strong>UnreliableNumber</strong> from a standard <code>number</code> value.<br>
Ideal for converting basic Lua numbers into UnreliableNumber instances without worrying about formatting.<br>
<strong><em>Example:</em></strong>
<code>UnreliableNumber.fromNumber(100023)</code>
]]
function UnreliableNumber.newFromNumber(num: number): UnreliableNumber
	printd("Creating new UnreliableNumber"):Tracing()
	local self = Utils.newFromNumber(num)
	setmetatable(self, UnreliableNumber)
	return self
end

--[[
Parses a string into an <strong>UnreliableNumber</strong>, preserving formatting details like underscores and decimal precision.<br>
Supports uncommon formats like underscores in decimal positions.<br>
<strong><em>Example:</em></strong>
<code>UnreliableNumber.newFromString("100.002_3")</code>
]]
function UnreliableNumber.newFromString(str: string): UnreliableNumber
	printd("Creating new UnreliableNumber"):Tracing()
	local self = Utils.newFromString(str)
	setmetatable(self, UnreliableNumber)
	return self
end

--[[
Creates an <strong>UnreliableNumber</strong> from a number with a scale suffix like <code>K</code>, <code>M</code>, or <code>B</code>.<br>
Useful for user-facing number representations where shorthand notation is common.<br>
<strong><em>Example:</em></strong> 
<code>UnreliableNumber.newFromSuffix("100.5K")</code>
]]
function UnreliableNumber.newFromSuffix(num: string): UnreliableNumber
	printd("Creating new UnreliableNumber"):Tracing()
	local self = Utils.newFromSuffix(num)
	setmetatable(self, UnreliableNumber)
	return self
end

-----------------------------------
--  Normalization and Rounding   --
-----------------------------------

--[[
Normalizes the number representation, adjusting integer and decimal parts to a standard format.
This removes unnecessary leading or trailing zeros and aligns decimal precision.
<strong><em>Example:</em></strong>
<code>num:normalize()</code>
]]
function UnreliableNumber:normalize()
	Normalizer.normalize(self)
end

--[[
Removes the decimal portion, discarding any fractional digits while preserving sign and integer value.
<strong><em>Example:</em></strong>
<code>num:removeDecimals()</code>
]]
function UnreliableNumber:removeDecimals()
	Normalizer.removeDecimals(self)
end

--[[
Shifts the decimal point left by <em>n</em> positions, effectively dividing by 10^n.
<strong><em>Example:</em></strong>
<code>num:shiftLeft(2)  -- equivalent to num / 100</code>
]]
function UnreliableNumber:shiftLeft(n: number)
	Normalizer.shiftLeft(self, n)
end

--[[
Shifts the decimal point right by <em>n</em> positions, effectively multiplying by 10^n.
<strong><em>Example:</em></strong>
<code>num:shiftRight(3) -- equivalent to num * 1000</code>
]]
function UnreliableNumber:shiftRight(n: number)
	Normalizer.shiftRight(self, n)
end

----------------------------
--  Arithmetic Operations --
----------------------------

--[[
Adds another <strong>UnreliableNumber</strong> (or number) to this one, returning a new instance.
Automatically converts Lua numbers to <strong>UnreliableNumber</strong> if needed.
<strong><em>Example:</em></strong>
<code>result = num1 + num2</code>
]]
function UnreliableNumber:add(other: UnreliableNumber): UnreliableNumber
	if type(other) == "number" then
		other = UnreliableNumber.newFromNumber(other)
	end
	local result = Arithmetic.add(self, other)
	local un = UnreliableNumber.new(result.sign, result.integer, result.trailingZeros, result.decimal)
	setmetatable(un, UnreliableNumber)
	return un
end

--[[
Subtracts another <strong>UnreliableNumber</strong> (or number) from this one, returning a new instance.
<strong><em>Example:</em></strong>
<code>result = num1 - 5</code>
]]
function UnreliableNumber:subtract(other: UnreliableNumber): UnreliableNumber
	if type(other) == "number" then
		other = UnreliableNumber.newFromNumber(other)
	end
	local result = Arithmetic.subtract(self, other)
	local un = UnreliableNumber.new(result.sign, result.integer, result.trailingZeros, result.decimal)
	setmetatable(un, UnreliableNumber)
	return un
end

--[[
Multiplies this <strong>UnreliableNumber</strong> by another (or number), returning a new instance.
<strong><em>Example:</em></strong>
<code>result = num:multiply(2.5)</code>
]]
function UnreliableNumber:multiply(other: UnreliableNumber): UnreliableNumber
	if type(other) == "number" then
		other = UnreliableNumber.newFromNumber(other)
	end
	local result = Arithmetic.multiply(self, other)
	local un = UnreliableNumber.new(result.sign, result.integer, result.trailingZeros, result.decimal)
	setmetatable(un, UnreliableNumber)
	return un
end

--[[
Divides this <strong>UnreliableNumber</strong> by another (or number), returning a new instance.
<strong><em>Example:</em></strong>
<code>result = num:divide(UnreliableNumber.newFromNumber(4))</code>
]]
function UnreliableNumber:divide(other: UnreliableNumber): UnreliableNumber
	if type(other) == "number" then
		other = UnreliableNumber.newFromNumber(other)
	end
	local result = Arithmetic.divide(self, other)
	local un = UnreliableNumber.new(result.sign, result.integer, result.trailingZeros, result.decimal)
	setmetatable(un, UnreliableNumber)
	return un
end

-----------------------------
--  Comparison Operations  --
-----------------------------

--[[
Returns <em>true</em> if this <strong>UnreliableNumber</strong> is greater than the other.
<strong><em>Example:</em></strong>
<code>if num1:isGreater(num2) then ... end</code>
]]
function UnreliableNumber:isGreater(other: UnreliableNumber): boolean
	if type(other) == "number" then
		other = UnreliableNumber.newFromNumber(other)
	end
	return Comparision.isGreater(self, other)
end

--[[
Returns <em>true</em> if this <strong>UnreliableNumber</strong> is lesser than the other.
<strong><em>Example:</em></strong>
<code>if num:isLesser(10) then ... end</code>
]]
function UnreliableNumber:isLesser(other: UnreliableNumber): boolean
	if type(other) == "number" then
		other = UnreliableNumber.newFromNumber(other)
	end
	return Comparision.isLesser(self, other)
end

--[[
Returns <em>true</em> if this <strong>UnreliableNumber</strong> equals the other (value and precision considered).
<strong><em>Example:</em></strong>
<code>if num1 == num2 then ... end</code>
]]
function UnreliableNumber:isEquals(other: UnreliableNumber): boolean
	if type(other) == "number" then
		other = UnreliableNumber.newFromNumber(other)
	end
	return Comparision.isEquals(self, other)
end

--[[
Returns <em>true</em> if this <strong>UnreliableNumber</strong> is greater than or equal to the other.
<strong><em>Example:</em></strong>
<code>num:isGreaterOrEquals(other)</code>
]]
function UnreliableNumber:isGreaterOrEquals(other: UnreliableNumber): boolean
	if type(other) == "number" then
		other = UnreliableNumber.newFromNumber(other)
	end
	return Comparision.isGreaterOrEquals(self, other)
end

--[[
Returns <em>true</em> if this <strong>UnreliableNumber</strong> is lesser than or equal to the other.
<strong><em>Example:</em></strong>
<code>num:isLesserOrEquals(100)</code>
]]
function UnreliableNumber:isLesserOrEquals(other: UnreliableNumber): boolean
	if type(other) == "number" then
		other = UnreliableNumber.newFromNumber(other)
	end
	return Comparision.isLesserOrEquals(self, other)
end

--[[
Compares this <strong>UnreliableNumber</strong> to another, returning -1, 0, or 1.
<strong><em>Example:</em></strong>
<code>local cmp = num:compare(5)</code>
]]
function UnreliableNumber:compare(other: UnreliableNumber): number
	if type(other) == "number" then
		other = UnreliableNumber.newFromNumber(other)
	end
	return Comparision.compare(self, other)
end

--[[
Returns <em>true</em> if this <strong>UnreliableNumber</strong> is zero.
<strong><em>Example:</em></strong>
<code>if num:isZero() then ... end</code>
]]
function UnreliableNumber:isZero(): boolean
	return Comparision.isZero(self)
end

----------------------------
--  Serialization Methods --
----------------------------

--[[
Serializes the number to the original string format, preserving formatting underscores.
<strong><em>Example:</em></strong>
<code>str = num:toString()</code>
]]
function UnreliableNumber:toString(): string
	return Serializer.toString(self)
end

--[[
Serializes to a full number string without formatting underscores.
<strong><em>Example:</em></strong>
<code>num:toFullNumber()</code>
]]
function UnreliableNumber:toFullNumber(): string
	return Serializer.toFullNumber(self)
end

--[[
Serializes with unit suffix notation (e.g., 'K', 'M') preserving formatting.
<strong><em>Example:</em></strong>
<code>num:toSuffix()</code>
]]
function UnreliableNumber:toSuffix(): string
	return Serializer.toSuffix(self)
end

--[[
Serializes to full suffix notation with expanded representation.
<strong><em>Example:</em></strong>
<code>num:toFullSuffix()</code>
]]
function UnreliableNumber:toFullSuffix(): string
	return Serializer.toFullSuffix(self)
end

--[[
Converts to a native Lua <strong>number</strong>, losing formatting details.
<strong><em>Example:</em></strong>
<code>val = num:toNumber()</code>
]]
function UnreliableNumber:toNumber(): number
	return Serializer.toNumber(self)
end

---------------------------
--  Utility Methods      --
---------------------------

--[[
Clones the current <strong>UnreliableNumber</strong>, creating an independent copy.
<strong><em>Example:</em></strong>
<code>copy = num:clone()</code>
]]
function UnreliableNumber:clone(): UnreliableNumber
	local copy = Utils.clone(self)
	setmetatable(copy, UnreliableNumber)
	return copy
end

----------------------------
--  Metatable Integration --
----------------------------

--[[
Defines addition operator using __add metamethod.
]]
function UnreliableNumber.__add(a: UnreliableNumber, b: UnreliableNumber): UnreliableNumber
	return a:add(b)
end

--[[
Defines subtraction operator using __sub metamethod.
]]
function UnreliableNumber.__sub(a: UnreliableNumber, b: UnreliableNumber)
	return a:subtract(b)
end

--[[
Defines multiplication operator using __mul metamethod.
]]
function UnreliableNumber.__mul(a: UnreliableNumber, b: UnreliableNumber)
	return a:multiply(b)
end

--[[
Defines division operator using __div metamethod.
]]
function UnreliableNumber.__div(a: UnreliableNumber, b: UnreliableNumber)
	return a:divide(b)
end

--[[
Defines equality operator using __eq metamethod.
]]
function UnreliableNumber.__eq(a: UnreliableNumber, b: UnreliableNumber)
	return a:isEquals(b)
end

--[[
Defines less-than operator using __lt metamethod.
]]
function UnreliableNumber.__lt(a: UnreliableNumber, b: UnreliableNumber)
	return a:isLesser(b)
end

--[[
Defines less-than-or-equal operator using __le metamethod.
]]
function UnreliableNumber.__le(a: UnreliableNumber, b: UnreliableNumber)
	return a:isLesserOrEquals(b)
end

--[[
Defines tostring metamethod to output the full number string.
]]
function UnreliableNumber.__tostring(self: UnreliableNumber)
	return self:toFullNumber()
end

setup()

return UnreliableNumber
