# ReadableRegex

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://jkrumbiegel.github.io/ReadableRegex.jl/stable)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://jkrumbiegel.github.io/ReadableRegex.jl/dev)
[![Build Status](https://travis-ci.com/jkrumbiegel/ReadableRegex.jl.svg?branch=master)](https://travis-ci.com/jkrumbiegel/ReadableRegex.jl)
[![Codecov](https://codecov.io/gh/jkrumbiegel/ReadableRegex.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/jkrumbiegel/ReadableRegex.jl)


## A package for people who don't want to learn or read regexes

ReadableRegex.jl gives you a syntax that is much easier to write and understand
than the rather cryptic standard Regex. The syntax is as close as possible to
a natural language description of the Regex. Here's an example:

Quickly, what does this regex do?

```julia
regex = r"[\+-]?(?:\d*\.)?\d+"
```

Compare with this:

```julia
regex = maybe(one_out_of("-", "+")) * maybe(any_number_of(DIGIT) * ".") * at_least_one(DIGIT)
```

Both of these match all kinds of floating point numbers like these:

`"1 2.0 .3 -.4 -5 60 700 800.9 +9000"`

But to understand the Regex you have to mentally parse it into the second version.
Why not avoid that effort?

ReadableRegex also saves you from escaping reserved regex characters like ".", so
there are not so many backslashes everywhere.


# Constants

These constants hold commonly used abbreviations:

| Constant | Regex |
| -- | -- |
| WORD | \w |
| NON_WORD | \W |
| DIGIT | \d |
| NON_DIGIT | \D |
| WHITESPACE | \s |
| NON_LINEBREAK | . |
| ANY | [\s\S] |
| BEGIN | ^ |
| END | $ |
| WORDBOUND | \b |
| NON_WORDBOUND | \B |

# These functions access the typical regex building blocks

```julia
at_least_one(regex)
at_least(n, regex)
between(low, high, regex)
maybe(regex)
any_of(regex)
matchonly(regex; [after, before, not_after, not_before])
one_out_of(regexs...)
```

