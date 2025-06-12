# 📐 Unreliable Number

After the "useless" `Unreliable Remove Events`, here comes: **Unreliable Number**!
A Lua library designed for **formatting-sensitive numeric values**. It preserves original formatting — leading/trailing zeros, decimal precision, suffixes — making it perfect for simulation games or UI displays where appearance matters more than arithmetic accuracy. It also ties into concepts like **Marginal Utility**.

---

## 📘 Table of Contents

1. [Introduction](https://github.com/DavldMA/Unreliable-Number-Module/tree/main?tab=readme-ov-file#-unreliable-number-1)
2. [Philosophy](https://github.com/DavldMA/Unreliable-Number-Module/tree/main?tab=readme-ov-file#%EF%B8%8F-philosophy)

   * [Why “Unreliable”?](#why-unreliable)
3. [Core Concepts](#core-concepts)

   * [Marginal Utility](#marginal-utility)
   * [The Subjectivity of Value](#the-subjectivity-of-value)
4. [Comparison with Other Libraries](#comparison-with-other-libraries)

   * [Unreliable vs. Others](#unreliable-vs-others)
   * [When to Use Each Module](#when-to-use-each-module)
5. [Features](#features)

   * [Core Fields](#core-fields)
   * [Constructors](#constructors)
   * [Arithmetic Operations](#arithmetic-operations)
   * [Formatting & Rounding](#formatting--rounding)
   * [Serialization](#serialization)
   * [Comparison Methods](#comparison-methods)
6. [Installation](#installation)
7. [Examples](#examples)
8. [API Reference](#api-reference)

   * [Constructors](#constructors-1)
   * [Formatting & Precision](#formatting--precision)
   * [Arithmetic](#arithmetic)
   * [Comparison](#comparison)
   * [Serialization](#serialization-1)
9. [Use Cases](#use-cases)
10. [Caveats](#caveats)

---

## 📐 Unreliable Number

`Unreliable Number` is a Lua library for **formatting-sensitive numeric values**. It preserves the original formatting — including leading/trailing zeros, decimal precision, and suffixes — making it ideal for simulation games or UI displays where the visual presentation of numbers matters more than precise arithmetic accuracy. It also connects with economic concepts like **Marginal Utility**.

---

## 🗣️ Philosophy

### Why “Unreliable”?

* It **prioritizes formatting preservation** over exact numeric correctness.
* Handles **very large values effortlessly** (e.g., `"1000T"`) without performance issues.
* Perfect for scenarios where **exact computation isn’t critical**, but consistent, visually familiar number representation is.

---

## 📉 Core Concepts

### Marginal Utility

**Utility** is the satisfaction or value gained from owning or consuming something.
**Marginal utility** is the extra satisfaction from one more unit—like an additional \$100.

> **Key insight:** as you have more of something (money, food, etc.), the extra satisfaction gained from each additional unit decreases. For example, an extra \$100 means a lot to someone struggling financially but barely matters to someone with trillions.

### The Subjectivity of Value

* Value is **not absolute**; it depends on how much an extra amount improves your wellbeing.
* \$100 is *life-changing* when you’re broke, but *irrelevant* when you’re absurdly wealthy.
* This library embraces that by focusing on **how numbers are perceived visually by the user**, rather than just their raw value.

---

## 🔄 Comparison with Other Libraries

| Feature / Module       | [BigNum](https://github.com/ennorehling/euler/blob/master/BigNum.lua) | [InfiniteMath](https://github.com/KdudeDev/InfiniteMath) | [Gigantix](https://github.com/DavldMA/Gigantix)              | [Unreliable Number](https://github.com/DavldMA/Unreliable-Number-Module)                           |
| ---------------------- | --------------------------------------------------------------------- | -------------------------------------------------------- | ------------------------------------------------------------ | -------------------------------------------------------------------------------------------------- |
| **Primary Focus**      | Arbitrary-precision integer arithmetic                                | Handling numbers beyond 10^308                           | Infinitely scalable numbers                                  | Efficient handling and formatting of large numbers, with focus on formatting rather than precision |
| **Limitations**        | No decimals; integer operations only                                  | Limited to ±10^308                                       | No decimals or negative numbers                              | Sacrifices precision for formatting                                                                |
| **Arithmetic Support** | Basic arithmetic operations                                           | Full arithmetic operations (+, -, \*, /, ^, %, etc.)     | Basic arithmetic operations                                  | Basic arithmetic operations                                                                        |
| **Ideal Use Case**     | Complex mathematical computations requiring arbitrary precision       | Handling extremely large numbers, e.g., in Roblox        | Efficient handling and formatting of large numbers in Roblox | Simulation games or UI displays prioritizing appearance over arithmetic accuracy                   |
| **Decimal Support**    | ❌ No decimals                                                         | ✅ Supports decimals                                      | ❌ No decimals                                                | ✅ Supports decimals                                                                                |

---

## 🧠 When to Use Each Module

* **BigNum**: For complex integer math with arbitrary precision where Lua's default is insufficient.
* **InfiniteMath**: When working with numbers exceeding floating-point limits (e.g., 10^308), especially in Roblox.
* **Gigantix**: For efficient large number handling and formatting in Roblox with performance focus.
* **Unreliable Number**: When the visual appearance of numbers and perceived value matter more than math accuracy, e.g., simulation games or UI displays.

---

## 💡 Features

### Core Fields

```lua
sign          -- number: 1 (positive) or -1 (negative)
integer       -- string: unsigned integer part
trailingZeros -- number: count of zeros at end of integer part
decimal       -- string: fractional part (may include trailing zeros)
```

### Constructors

```lua
UnreliableNumber.new(sign, integer, trailingZeros, decimal)
UnreliableNumber.newFromNumber(num)    -- approximate from Lua number
UnreliableNumber.newFromString(str)    -- preserve exact input format
UnreliableNumber.newFromSuffix(str)    -- parse suffixes like "1K", "2.5M"
```

### Arithmetic Operations (format-aware)

* `:add(...)`, `:subtract(...)`
* `:multiply(...)`, `:divide(...)`
* Supports operator overloading: `+`, `-`, `*`, `/`

### Formatting & Rounding

* `:normalize(config?)` — trim/expand zeros, set decimal precision
* `:removeDecimals()` — drop fractional part
* `:shiftLeft(n)` / `:shiftRight(n)` — visually move decimal point
* `:round("floor" | "ceil" | "nearest")` — visual rounding (not mathematically exact)

### Serialization

* `:toString()` — string preserving original formatting
* `:toFullNumber()` — full numeric string without formatting artifacts
* `:toSuffix()` — compact suffix format ("1K", "2.5M")
* `:toFullSuffix()` — expanded suffix number
* `:toNumber()` — converts to Lua number (may lose fidelity)

### Comparison Methods

* `:isEquals()`, `:isGreater()`, `:isLesser()`, `:isZero()`
* `:compare()` returns `-1`, `0`, or `1`
* Supports `==`, `<`, `<=` metamethods

---

## Installation

Copy the module's `.lua` files into your project or require it directly:

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

-- From suffix notation
local b = U.newFromSuffix("2.5M")
print(b:toSuffix())       -- Output: "2.5M"
print(b:toFullNumber())   -- Output: "2500000"

-- Arithmetic operations
local c = a + b * U.newFromNumber(2)
print(c:toSuffix())       -- e.g., "5.0001M" (format preserved)

-- Comparison
if b:isGreater(a) then
   print("b is visually larger than a")
end

-- Rounding
b:round("floor")
print(b:toString())       -- e.g., "2M"
```

---

## API Reference

### Constructors

| Function                                     | Purpose                     |
| -------------------------------------------- | --------------------------- |
| `new(sign, integer, trailingZeros, decimal)` | Build manually              |
| `newFromNumber(num)`                         | Approximate from Lua number |
| `newFromString(str)`                         | Preserve exact input format |
| `newFromSuffix(str)`                         | Parse suffix notation       |

### Formatting & Precision

* `:normalize(config?)`
* `:removeDecimals()`
* `:shiftLeft(n) / :shiftRight(n)`
* `:round(mode)`

### Arithmetic

* `:add()`, `:subtract()`, `:multiply()`, `:divide()`
* Supports `+`, `-`, `*`, `/` operators

### Comparison

* `:isEquals()`, `:isGreater()`, `:isLesser()`, etc.
* `:compare()` → -1, 0, 1
* Overloads `==`, `<`, `<=`

### Serialization

* `:toString()`, `:toFullNumber()`
* `:toSuffix()`, `:toFullSuffix()`
* `:toNumber()`

---

## Use Cases

* Simulation games with ever-increasing resources ("1K", "2.5M", etc.)
* UI dashboards requiring exact user-input formatting
* Read-only displays where preserving original numeric representation is critical

---

## Caveats

* Not designed for **precise math** — focused on display and formatting
* Can misrepresent theoretically infinite buys, but manageable in practice
* Operators and rounding are **format-focused**, not mathematically strict
