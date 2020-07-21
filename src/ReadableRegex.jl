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
export at_least_one
export at_least
export between
export exactly
export maybe
export any_of
export matchonly
export one_out_of

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

# Convert a string with special regex chars to one where they are all escaped with backslashes.
escaped(s::String) = replace(s, r"([\\\.\+\^\$])" => s"\\\1")

# Define handy conversion routines for RegexStrings.
Base.convert(::Type{RegexString}, s::String) = RegexString(escaped(s))
Base.convert(::Type{RegexString}, rs::RegexString) = rs
Base.convert(::Type{RegexString}, c::Char) = RegexString(escaped(string(c)))
Base.convert(::Type{RegexString}, s::Set{Char}) = RegexString("[$(join(s))]")
Base.convert(::Type{RegexString}, sr::StepRange{Char, Int}) = RegexString("[$(sr.start)-$(sr.stop)]")

# These are functions that give the typical regex logic building blocks.
at_least_one(r::RegexString) = RegexString(noncapturing_group_or_append(r.s, "+"))
at_least(n::Int, r::RegexString) = RegexString(noncapturing_group_or_append(r.s, "{$n,}"))
between(low::Int, high::Int, r::RegexString) = RegexString(noncapturing_group_or_append(r.s, "{$low,$high}"))
exactly(n::Int, r::RegexString) = RegexString(noncapturing_group_or_append(r.s, "{$n}"))

maybe(r::RegexString) = RegexString(noncapturing_group_or_append(r.s, "?"))
any_of(r::RegexString) = RegexString(noncapturing_group_or_append(r.s, "*"))
followed_by(r::RegexString, by::RegexString) = RegexString(noncapturing_group_or_token(r.s) * "(?=$(by.s))")
not_followed_by(r::RegexString, by::RegexString) = RegexString(noncapturing_group_or_token(r.s) * "(?!$(by.s))")
preceded_by(r::RegexString, by::RegexString) = RegexString("(?<=$(by.s))" * noncapturing_group_or_token(r.s))
not_preceded_by(r::RegexString, by::RegexString) = RegexString("(?<!$(by.s))" * noncapturing_group_or_token(r.s))


function matchonly(r;
        after = nothing,
        before = nothing,
        not_after = nothing,
        not_before = nothing)

    if sum((!isnothing).((after, before, not_after, not_before))) != 1
        error("This function takes exactly one keyword argument that is not nothing.")
    end

    if !isnothing(after)
        preceded_by(r, convert(RegexString, after))
    elseif !isnothing(before)
        followed_by(r, convert(RegexString, before))
    elseif !isnothing(not_after)
        not_preceded_by(r, convert(RegexString, not_after))
    elseif !isnothing(not_before)
        not_followed_by(r, convert(RegexString, not_before))
    end
end


one_out_of(options::RegexString...) = RegexString((join([noncapturing_group_or_token(r.s) for r in options], "|")))

at_least_one(x) = at_least_one(convert(RegexString, x))
at_least(n::Int, x) = at_least(n, convert(RegexString, x))
between(low::Int, high::Int, x) = between(low, high, convert(RegexString, x))
exactly(n::Int, x) = exactly(n, convert(RegexString, x))

maybe(x) = maybe(convert(RegexString, x))
any_of(x) = any_of(convert(RegexString, x))
one_out_of(args...) = one_out_of(convert.(RegexString, args)...)


# Define the multiplication operator on RegexStrings as concatenation like Strings.
# Anything can be concatenated if it can be converted to a RegexString.
Base.:*(r1::RegexString, r2::RegexString) = RegexString(r1.s * r2.s)
Base.:*(anything, r::RegexString) = convert(RegexString, anything) * r
Base.:*(r::RegexString, anything) = r * convert(RegexString, anything)


Base.Regex(r::RegexString) = Regex(r.s)
Base.match(rs::RegexString, x) = Base.match(Regex(rs), x)
Base.eachmatch(rs::RegexString, x) = Base.eachmatch(Regex(rs), x)

end # module
