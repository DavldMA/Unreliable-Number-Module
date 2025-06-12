# 📐 UnreliableNumber 

After we got the "useless" `Unreliable Remove Events`, I present you: `Unreliable Number`! `Unreliable Number` is a Lua library designed for formatting-sensitive numeric values. It preserves original formatting—leading/trailing zeros, decimal precision, suffixes—making it ideal for simulation games, or UI displays where appearance matters more than arithmetic accuracy. It is also usefull in terms of Marginal Utility.

## Why “Unreliable”?

* It **prioritizes formatting preservation** over exact numeric correctness.
* Handles **very large values effortlessly** (e.g., "1000T") without any performance hiccups.
* Ideal for scenarios where **exact computation isn’t critical**, but consistent, visually familiar number representation is.

## 📉 What is Marginal Utility?

**Utility** is the satisfaction or value you gain from owning or consuming something. **Marginal utility** is the extra satisfaction you get from one more unit — like an additional \$100.

###### The key insight: as you have more of something (money, food, etc.), the extra satisfaction you get from each additional unit decreases. For example, an extra \$100 means a lot to someone struggling financially but barely makes a dent to someone with trillions.

## 🧠 The Subjectivity of Value

* Value isn’t absolute — it’s subjective and depends on how much an extra amount improves your wellbeing.
* \$100 is *life-changing* when you’re broke but almost *irrelevant* when you’re absurdly wealthy.
* This library embraces that idea by focusing on **how numbers are perceived visually by the user**, rather than just their raw value.

---

## Features

### Core Fields

```lua
sign             -- number: 1 (positive) or -1 (negative)
integer          -- string: unsigned integer part
trailingZeros    -- number: count of zeros at end of integer part
decimal          -- string: fractional part (can include trailing zeros)
```

### Constructors

```lua
UnreliableNumber.new(sign, integer, trailingZeros, decimal)
UnreliableNumber.newFromNumber(num)    -- approximation from Lua number
UnreliableNumber.newFromString(str)    -- exact preserve input format
UnreliableNumber.newFromSuffix(str)    -- parse "1K", "2.5M", etc.
```

### Arithmetic Operations (format-aware)

* `:add(...)`, `:subtract(...)`
* `:multiply(...)`, `:divide(...)`

Also supports operator overloading: `+`, `-`, `*`, `/`.

### Formatting & Rounding

* `:normalize(config?)` — trim or expand zeros, set decimal precision.
* `:removeDecimals()` — drop fractional part.
* `:shiftLeft(n)` / `:shiftRight(n)` — move decimal point visually.
* `:round("floor"|"ceil"|"nearest")` — visual rounding (not mathematically precise).

### Serialization

* `:toString()` — returns string preserving all original formatting.
* `:toFullNumber()` — full numeric string without formatting artifacts.
* `:toSuffix()` — compact suffix format ("1K", "2.5M").
* `:toFullSuffix()` — expanded suffix number.
* `:toNumber()` — converts to native Lua number (may lose fidelity).

### Comparison Methods

* `:isEquals()`, `:isGreater()`, `:isLesser()`, `:isZero()`, etc.
* `:compare()` returns -1, 0, or 1.
* Suports `==`, `<`, `<=` metamethods.

---

## Installation

Copy the module's `.lua` files into your project or require it via your module loader:

```lua
local UnreliableNumber = require(path_to.UnreliableNumber)
```

---

## Examples

```lua
local U = UnreliableNumber

-- From formatted string
local a = U.newFromString("00100.5000")
a:normalize({ trimLeadingZeros = true, preserveZeros = false })
assert(a:toString() == "100.5")

-- From suffix
local b = U.newFromSuffix("2.5M")
print(b:toSuffix())       -- "2.5M"
print(b:toFullNumber())   -- "2500000"

-- Arithmetic
local c = a + b * U.newFromNumber(2)
print(c:toSuffix())       -- e.g. "5.0001M" (format preserved)

-- Comparing
if b:isGreater(a) then
   print("b is visually larger than a")
end

-- Rounding
b:round("floor")
print(b:toString())       -- e.g. "2M"
```

---

## API Reference

### Constructors

| Function                                     | Purpose                     |
| -------------------------------------------- | --------------------------- |
| `new(sign, integer, trailingZeros, decimal)` | Build manually              |
| `newFromNumber(num)`                         | Approximate from Lua number |
| `newFromString(str)`                         | Preserve exact input format |
| `newFromSuffix(str)`                         | Read suffix notation        |

### Formatting & Precision

* `:normalize(config?)`
* `:removeDecimals()`
* `:shiftLeft(n) / :shiftRight(n)`
* `:round(mode)`

### Arithmetic

* `:add()`, `:subtract()`, `:multiply()`, `:divide()`
* Supports `+`, `-`, `*`, `/` operators.

### Comparison

* `:isEquals()`, `:isGreater()`, `:isLesser()`, etc.
* `:compare()` → -1, 0, 1
* `==`, `<`, `<=` overloaded.

### Serialization

* `:toString()`, `:toFullNumber()`
* `:toSuffix()`, `:toFullSuffix()`
* `:toNumber()`

---

## Use Cases

* Simulation games with ever-increasing resources like "1K", "2.5M".
* UI dashboards requiring exact user-input formatting.
* Read-only displays where pristine representation is critical.

---

## Caveats

* Not for accurate math—designed for display.
* Can theoretically misrepresent truly infinite buys—but in practice, manageable.
* Operators and rounding are *format-focused*, not mathematically strict.
