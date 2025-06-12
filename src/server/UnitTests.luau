local TestService = game:GetService("TestService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UN = require(ReplicatedStorage.Modules.UnreliableNumber)
local printd = UN.Debugger


local function bn(n)
	return UN.newFromNumber(n)
end

local function runTest(name, fn)
	local ok, err = pcall(fn)
	TestService:Check(ok, name .. (ok and " passed" or " failed: " .. tostring(err)))
	local str = (ok and "PASSED" or ("FAILED: " .. tostring(err)))
	str = name .. " " .. str
	printd(str):Success()
end


runTest("add: integer addition", function()

	assert(UN.add(bn(5), bn(3)):toNumber() == 8, "Expected 5 + 3 to equal 8")
end)
runTest("add: negative and positive", function()
	assert(UN.add(bn(-2), bn(7)):toNumber() == 5, "Expected -2 + 7 to equal 5")
end)
runTest("add: decimal addition", function()
	assert(math.abs(UN.add(bn(1.25), bn(2.75)):toNumber() - 4) < 1e-10, "Expected 1.25 + 2.75 to be approximately 4")
end)

-- Subtraction tests
runTest("subtract: integer subtraction", function()
	assert(UN.subtract(bn(10), bn(4)):toNumber() == 6, "Expected 10 - 4 to equal 6")
end)
runTest("subtract: negative result", function()
	assert(UN.subtract(bn(4), bn(10)):toNumber() == -6, "Expected 4 - 10 to equal -6")
end)

-- Multiplication tests
runTest("multiply: integer multiplication", function()
	assert(UN.multiply(bn(6), bn(7)):toNumber() == 42, "Expected 6 * 7 to equal 42")
end)
runTest("multiply: decimal multiplication", function()
	assert(math.abs(UN.multiply(bn(1.5), bn(2.0)):toNumber() - 3) < 1e-10, "Expected 1.5 * 2.0 to be approximately 3")
end)

-- Division tests
runTest("divide: integer division", function()
	assert(UN.divide(bn(9), bn(3)):toNumber() == 3, "Expected 9 / 3 to equal 3")
end)
runTest("divide: fractional result", function()
	assert(math.abs(UN.divide(bn(1), bn(4)):toNumber() - 0.25) < 1e-10, "Expected 1 / 4 to be approximately 0.25")
end)
runTest("divide: division by zero errors", function()
	local function divByZero()
		UN.divide(bn(5), bn(0))
	end
	local ok = pcall(divByZero)
	assert(not ok, "Expected division by zero to throw an error")
end)

printd("ArithmeticTests completed."):Success()