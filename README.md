# ReadableRegex

[![Build Status](https://travis-ci.com/jkrumbiegel/ReadableRegex.jl.svg?branch=master)](https://travis-ci.com/jkrumbiegel/ReadableRegex.jl)
[![Codecov](https://codecov.io/gh/jkrumbiegel/ReadableRegex.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/jkrumbiegel/ReadableRegex.jl)


## A package for people who don't want to learn or read regexes

ReadableRegex.jl gives you a syntax that is much easier to write and understand
than the rather cryptic standard Regex. The syntax is as close as possible to
a natural language description of the Regex.
Especially for nested and grouped expressions with special characters it is orders of magnitudes easier to understand than
a simple regex string. Here's an example:

### Quickly, what does this regex do?

```julia
regex = r"[\+-]?(?:\d*\.)?\d+"
```

### Compare with this:

```julia
regex = maybe(["-", "+"]) *
            maybe(any_of(DIGIT) * ".") *
            at_least_one(DIGIT)
```

Both of these match all kinds of floating point numbers like these:

`"1 2.0 .3 -.4 -5 60 700 800.9 +9000"`

But to understand the Regex you have to mentally parse it into the second version.
Why not avoid that effort?

ReadableRegex also escapes reserved regex characters like "." by default, saving you a lot of backslashes.

## How does it work?

ReadableRegex uses a simple intermediary type `RegexString` which holds a string
representation of a regex, the same thing you'd normally write yourself.

These `RegexString`s can be concatenated together with the `*` operator.
You can convert them into a `Regex` by calling `Regex(rs::RegexString)`,
or use them directly with `match` and `eachmatch`.


## Constants

These constants hold commonly used abbreviations:

| Constant | Regex |
| -- | -- |
| `WORD` | `\w` |
| `NON_WORD` | `\W` |
| `DIGIT` | `\d` |
| `NON_DIGIT` | `\D` |
| `WHITESPACE` | `\s` |
| `NON_LINEBREAK` | `.` |
| `ANY` | `[\s\S]` |
| `BEGIN` | `^` |
| `END` | `$` |
| `WORDBOUND` | `\b` |
| `NON_WORDBOUND` | `\B` |

## These functions access the typical regex building blocks

| Function | Purpose |
| --- | --- |
| `at_least_one(target)` | Match one or more repetitions of `target`|
| `at_least(n, target)` | Match at least `n` repetitions of `target`|
| `between(low, high, target)` | Match between `low` and `high` repetitions of `target` |
| `maybe(target)` | Match zero or one repetitions of `target` |
| `exactly(n, target)` | Match exactly `n` repetitions of `target` |
| `any_of(target)` | Match zero to infinity repetitions of `target` |
| `matchonly(target; [after, before, not_after, not_before])` | Match `target` only if it is either `before`, `after`, `not_after`, or `not_before` other matches. Only one keyword can be set at a time. |
| `one_out_of(targets...)` | Match one target out of all given `targets` (the first in order if multiple could match). |
| `capture(target; [as])` | Create a numbered capture group that you can back reference, or name it optionally with the `as` keyword. |
| `reference(i::Int)` | Back reference to capture group number `i` (1 based counting) |
| `reference(name)` | Back reference to the capture group named `name` |
| `chars(s::String)` | Match any one of the characters in string `s` |

## Creating RegexStrings manually

If you need to, you can create a `RegexString` using its constructor with a properly escaped string.

```julia
r = RegexString("\\w")
```

Alternatively, there is the `@rs_str` macro which allows you to use normal regex syntax, without special escaping rules.

```julia
r = rs"\w"
```

This can also be useful if you want to start a chain of concatenated parts where the multiplication operator needs one of the two first elements to be a `RegexString`.

```julia
r = rs"c" * ["at", "ool", "ute"]
```

## Conversions

Some constructs from Base Julia are useful to express building blocks of regular expression.
You can define `Base.convert(::Type{RegexString}, obj)` to use these directly in ReadableRegex expressions.
All building block functions call `convert` on their inputs, and so does the multiplication operator `*`.

Some predefined examples:

### `String` and `Char`

Strings and Chars are escaped when converted, so you can use `.+[]^$` etc. without escaping them manually.

```julia
at_least_one("+")
maybe("[text in brackets]")
```

### `StepRange{Char, Int}`

Char ranges can be used directly and match any char within the range.

```julia
at_least_one('a':'z')
between(1, 4, '🌑':'🌘')
```

### `AbstractVector` and `Tuple`

Using an AbstractVector or a Tuple is the same as calling `one_out_of(vec_or_tup...)`.
That means you can use any element that is itself convertible to a `RegexString`.

```julia
exactly(3, ['a':'z', "ha"])
maybe(('x', 'Y'))
```

## Compilation

You can use the `@compile` macro to build a finished `Regex` out of the following expression.
This might help to avoid some runtime costs. You can only use literals and the ReadableRegex constants
in these expressions.

```julia
julia> @allocated BEGIN * maybe('a':'z') * exactly(1, ["hello", "hi", "what's up"]) * END
2528

julia> @allocated @compile BEGIN * maybe('a':'z') * exactly(1, ["hello", "hi", "what's up"]) * END
0
```
