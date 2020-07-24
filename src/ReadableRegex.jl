module ReadableRegex

export RegexString
export @rs_str
export WORD
export NON_WORD
export DIGIT
export NON_DIGIT
export WHITESPACE
export NON_LINEBREAK
export ANY
export BEGIN
export END
export WORDBOUND
export NON_WORDBOUND
export one_or_more
export at_least
export between
export exactly
export maybe
export zero_or_more
export matchonly
export one_out_of
export capture
export reference
export chars
export not_chars
export @compile

export LETTER
export UPPERCASE
export LOWERCASE
export TITLECASE
export MODIFIER_LETTER
export OTHER_LETTER
export MARK
export NONSPACING_MARK
export SPACING_COMBINING_MARK
export ENCLOSING_MARK
export NUMBER
export DEC_DIGIT_NUMBER
export LETTER_NUMBER
export OTHER_NUMBER
export SYMBOL
export MATH_SYMBOL
export CURRENCY
export MODIFIER_SYMBOL
export OTHER_SYMBOL
export PUNCTUATION
export CONNECTOR_PUNCT
export DASH_PUNCT
export OPEN_PUNCT
export CLOSE_PUNCT
export INITIAL_PUNCT
export FINAL_PUNCT
export OTHER_PUNCT
export SEPARATOR
export SPACE_SEP
export LINE_SEP
export PARAGRAPH_SEP
export OTHER
export CONTROL
export FORMAT
export SURROGATE
export PRIVATE_USE
export UNASSIGNED
export NON_LETTER
export NON_UPPERCASE
export NON_LOWERCASE
export NON_TITLECASE
export NON_MODIFIER_LETTER
export NON_OTHER_LETTER
export NON_MARK
export NON_NONSPACING_MARK
export NON_SPACING_COMBINING_MARK
export NON_ENCLOSING_MARK
export NON_NUMBER
export NON_DEC_DIGIT_NUMBER
export NON_LETTER_NUMBER
export NON_OTHER_NUMBER
export NON_SYMBOL
export NON_MATH_SYMBOL
export NON_CURRENCY
export NON_MODIFIER_SYMBOL
export NON_OTHER_SYMBOL
export NON_PUNCTUATION
export NON_CONNECTOR_PUNCT
export NON_DASH_PUNCT
export NON_OPEN_PUNCT
export NON_CLOSE_PUNCT
export NON_INITIAL_PUNCT
export NON_FINAL_PUNCT
export NON_OTHER_PUNCT
export NON_SEPARATOR
export NON_SPACE_SEP
export NON_LINE_SEP
export NON_PARAGRAPH_SEP
export NON_OTHER
export NON_CONTROL
export NON_FORMAT
export NON_SURROGATE
export NON_PRIVATE_USE
export NON_UNASSIGNED

"""
    RegexString(s::String)

Holds a string meant as the raw format of a regular expression.
This should always be convertible to a valid regex, so it's best
not to construct one yourself. Use the builder functions instead.
"""
struct RegexString
    s::String
end

macro rs_str(exp)
    :(RegexString($exp))
end

function noncapturing_group_or_append(inner::String, outer::String)
    if isempty(inner)
        error("Empty inner string")
    else
        noncapturing_group_or_token(inner) * outer
    end
end

# This helps keeping the nesting code simple,
# because there can be no interactions beyond the group barrier.
function noncapturing_group_or_token(s::String)
    if length(s) == 1
        s
    else
        "(?:" * s * ")"
    end
end

# Define helper constants.
const WORD = rs"\w"
const NON_WORD = rs"\W"
const DIGIT = rs"\d"
const NON_DIGIT = rs"\D"
const WHITESPACE = rs"\s"
const NON_LINEBREAK = rs"."
const ANY = rs"[\s\S]"
const BEGIN = rs"^"
const END = rs"$"
const WORDBOUND = rs"\b"
const NON_WORDBOUND = rs"\B"

const LETTER = rs"\p{L}"
const UPPERCASE = rs"\p{Lu}"
const LOWERCASE = rs"\p{Ll}"
const TITLECASE = rs"\p{Lt}"
const MODIFIER_LETTER = rs"\p{Lm}"
const OTHER_LETTER = rs"\p{Lo}"
const MARK = rs"\p{M}"
const NONSPACING_MARK = rs"\p{Mn}"
const SPACING_COMBINING_MARK = rs"\p{Mc}"
const ENCLOSING_MARK = rs"\p{Me}"
const NUMBER = rs"\p{N}"
const DEC_DIGIT_NUMBER = rs"\p{Nd}"
const LETTER_NUMBER = rs"\p{Nl}"
const OTHER_NUMBER = rs"\p{No}"
const SYMBOL = rs"\p{S}"
const MATH_SYMBOL = rs"\p{Sm}"
const CURRENCY = rs"\p{Sc}"
const MODIFIER_SYMBOL = rs"\p{Sk}"
const OTHER_SYMBOL = rs"\p{So}"
const PUNCTUATION = rs"\p{P}"
const CONNECTOR_PUNCT = rs"\p{Pc}"
const DASH_PUNCT = rs"\p{Pd}"
const OPEN_PUNCT = rs"\p{Ps}"
const CLOSE_PUNCT = rs"\p{Pe}"
const INITIAL_PUNCT = rs"\p{Pi}"
const FINAL_PUNCT = rs"\p{Pf}"
const OTHER_PUNCT = rs"\p{Po}"
const SEPARATOR = rs"\p{Z}"
const SPACE_SEP = rs"\p{Zs}"
const LINE_SEP = rs"\p{Zl}"
const PARAGRAPH_SEP = rs"\p{Zp}"
const OTHER = rs"\p{C}"
const CONTROL = rs"\p{Cc}"
const FORMAT = rs"\p{Cf}"
const SURROGATE = rs"\p{Cs}"
const PRIVATE_USE = rs"\p{Co}"
const UNASSIGNED = rs"\p{Cn}"

const NON_LETTER = rs"\P{L}"
const NON_UPPERCASE = rs"\P{Lu}"
const NON_LOWERCASE = rs"\P{Ll}"
const NON_TITLECASE = rs"\P{Lt}"
const NON_MODIFIER_LETTER = rs"\P{Lm}"
const NON_OTHER_LETTER = rs"\P{Lo}"
const NON_MARK = rs"\P{M}"
const NON_NONSPACING_MARK = rs"\P{Mn}"
const NON_SPACING_COMBINING_MARK = rs"\P{Mc}"
const NON_ENCLOSING_MARK = rs"\P{Me}"
const NON_NUMBER = rs"\P{N}"
const NON_DEC_DIGIT_NUMBER = rs"\P{Nd}"
const NON_LETTER_NUMBER = rs"\P{Nl}"
const NON_OTHER_NUMBER = rs"\P{No}"
const NON_SYMBOL = rs"\P{S}"
const NON_MATH_SYMBOL = rs"\P{Sm}"
const NON_CURRENCY = rs"\P{Sc}"
const NON_MODIFIER_SYMBOL = rs"\P{Sk}"
const NON_OTHER_SYMBOL = rs"\P{So}"
const NON_PUNCTUATION = rs"\P{P}"
const NON_CONNECTOR_PUNCT = rs"\P{Pc}"
const NON_DASH_PUNCT = rs"\P{Pd}"
const NON_OPEN_PUNCT = rs"\P{Ps}"
const NON_CLOSE_PUNCT = rs"\P{Pe}"
const NON_INITIAL_PUNCT = rs"\P{Pi}"
const NON_FINAL_PUNCT = rs"\P{Pf}"
const NON_OTHER_PUNCT = rs"\P{Po}"
const NON_SEPARATOR = rs"\P{Z}"
const NON_SPACE_SEP = rs"\P{Zs}"
const NON_LINE_SEP = rs"\P{Zl}"
const NON_PARAGRAPH_SEP = rs"\P{Zp}"
const NON_OTHER = rs"\P{C}"
const NON_CONTROL = rs"\P{Cc}"
const NON_FORMAT = rs"\P{Cf}"
const NON_SURROGATE = rs"\P{Cs}"
const NON_PRIVATE_USE = rs"\P{Co}"
const NON_UNASSIGNED = rs"\P{Cn}"

# Convert a string with special regex chars to one where they are all escaped with backslashes.
escaped(s::String) = replace(s, r"([\\\.\+\^\$])" => s"\\\1")

# Define handy conversion routines for RegexStrings.
Base.convert(::Type{RegexString}, s::String) = RegexString(escaped(s))
Base.convert(::Type{RegexString}, rs::RegexString) = rs
Base.convert(::Type{RegexString}, c::Char) = RegexString(escaped(string(c)))
Base.convert(::Type{RegexString}, sr::StepRange{Char, Int}) = RegexString("[$(sr.start)-$(sr.stop)]")
Base.convert(::Type{RegexString}, list::Union{AbstractVector, Tuple}) = one_out_of(list...)


_c(x) = convert(RegexString, x)

# These are functions that give the typical regex logic building blocks.
one_or_more(r) = RegexString(noncapturing_group_or_append(_c(r).s, "+"))
at_least(n::Int, r) = RegexString(noncapturing_group_or_append(_c(r).s, "{$n,}"))
between(low::Int, high::Int, r) = RegexString(noncapturing_group_or_append(_c(r).s, "{$low,$high}"))
exactly(n::Int, r) = RegexString(noncapturing_group_or_append(_c(r).s, "{$n}"))

maybe(r) = RegexString(noncapturing_group_or_append(_c(r).s, "?"))
zero_or_more(r) = RegexString(noncapturing_group_or_append(_c(r).s, "*"))
followed_by(r, by) = RegexString(noncapturing_group_or_token(_c(r).s) * "(?=$(_c(by).s))")
not_followed_by(r, by) = RegexString(noncapturing_group_or_token(_c(r).s) * "(?!$(_c(by).s))")
preceded_by(r, by) = RegexString("(?<=$(_c(by).s))" * noncapturing_group_or_token(_c(r).s))
not_preceded_by(r, by) = RegexString("(?<!$(_c(by).s))" * noncapturing_group_or_token(_c(r).s))


function matchonly(r;
        after = nothing,
        before = nothing,
        not_after = nothing,
        not_before = nothing)

    if sum((!isnothing).((after, before, not_after, not_before))) != 1
        error("This function takes exactly one keyword argument that is not nothing.")
    end

    if !isnothing(after)
        preceded_by(r, after)
    elseif !isnothing(before)
        followed_by(r, before)
    elseif !isnothing(not_after)
        not_preceded_by(r, not_after)
    elseif !isnothing(not_before)
        not_followed_by(r, not_before)
    end
end

one_out_of(args...) = RegexString(noncapturing_group_or_token(join([noncapturing_group_or_token(_c(r).s) for r in args], "|")))

function capture(r; as = nothing)
    if isnothing(as)
        RegexString("($(_c(r).s))")
    else
        RegexString("(?<$as>$(_c(r).s))")
    end
end

reference(i::Int) = RegexString("\\$i")
reference(name) = RegexString("\\k<$name>")

chars(args...) =     RegexString("""[$(join((_charset(arg) for arg in args), ""))]""")
not_chars(args...) = RegexString("""[^$(join((_charset(arg) for arg in args), ""))]""")

_charset(s::String) = s
_charset(c::Char) = c
_charset(sr::StepRange{Char, Int}) = "$(sr.start)-$(sr.stop)"
_charset(rs::RegexString) = rs.s

# Define the multiplication operator on RegexStrings as concatenation like Strings.
# Anything can be concatenated if it can be converted to a RegexString.
Base.:*(r1::RegexString, r2::RegexString) = RegexString(r1.s * r2.s)
Base.:*(anything, r::RegexString) = convert(RegexString, anything) * r
Base.:*(r::RegexString, anything) = r * convert(RegexString, anything)


Base.Regex(r::RegexString) = Regex(r.s)
Base.match(rs::RegexString, x) = Base.match(Regex(rs), x)
Base.eachmatch(rs::RegexString, x) = Base.eachmatch(Regex(rs), x)


macro compile(exp)
    regexstring = @eval $exp
    Regex(regexstring.s)
end

end # module
