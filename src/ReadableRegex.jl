module ReadableRegex

export RegexString
export @rs_str
export WORD
export NOT_WORD
export DIGIT
export NOT_DIGIT
export WHITESPACE
export ANY_BUT_LINEBREAK
export ANY
export BEGIN
export END
export WORDBOUND
export NOT_WORDBOUND
export at_least_one
export at_least
export between
export maybe
export any_number_of
export matchonly
export one_of

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

function noncapturing_group_or_token(s::String)
    if length(s) == 1
        s
    else
        "(?:" * s * ")"
    end
end

const WORD = rs"\w"
const NOT_WORD = rs"\W"
const DIGIT = rs"\d"
const NOT_DIGIT = rs"\D"
const WHITESPACE = rs"\s"
const ANY_BUT_LINEBREAK = rs"."
const ANY = rs"[\s\S]"
const BEGIN = rs"^"
const END = rs"$"
const WORDBOUND = rs"\b"
const NOT_WORDBOUND = rs"\B"

escaped(s::String) = replace(s, r"([\\\.\+\^\$])" => s"\\\1")

to_regexstring(s::String) = RegexString(escaped(s))
to_regexstring(rs::RegexString) = rs
to_regexstring(c::Char) = RegexString(escaped(string(c)))
to_regexstring(s::Set{Char}) = RegexString("[$(join(s))]")
to_regexstring(sr::StepRange{Char, Int}) = RegexString("[$(sr.start)-$(sr.stop)]")

at_least_one(r::RegexString) = RegexString(noncapturing_group_or_append(r.s, "+"))
at_least(n::Int, r::RegexString) = RegexString(noncapturing_group_or_append(r.s, "{$n,}"))
between(low::Int, high::Int, r::RegexString) = RegexString(noncapturing_group_or_append(r.s, "{$low,$high}"))

maybe(r::RegexString) = RegexString(noncapturing_group_or_append(r.s, "?"))
any_number_of(r::RegexString) = RegexString(noncapturing_group_or_append(r.s, "*"))
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
        preceded_by(r, to_regexstring(after))
    elseif !isnothing(before)
        followed_by(r, to_regexstring(before))
    elseif !isnothing(not_after)
        not_preceded_by(r, to_regexstring(not_after))
    elseif !isnothing(not_before)
        not_followed_by(r, to_regexstring(not_before))
    end
end


one_of(options::RegexString...) = RegexString((join([noncapturing_group_or_token(r.s) for r in options], "|")))

at_least_one(x) = at_least_one(to_regexstring(x))
at_least(n::Int, x) = at_least(n, to_regexstring(x))
between(low::Int, high::Int, x) = between(low, high, to_regexstring(x))
maybe(x) = maybe(to_regexstring(x))
any_number_of(x) = any_number_of(to_regexstring(x))
one_of(args...) = one_of(to_regexstring.(args)...)

Base.:*(r1::RegexString, r2::RegexString) = RegexString(r1.s * r2.s)
Base.:*(s::String, r::RegexString) = to_regexstring(s) * r
Base.:*(r::RegexString, s::String) = r * to_regexstring(s)


Base.Regex(r::RegexString) = Regex(r.s)
Base.match(rs::RegexString, x) = Base.match(Regex(rs), x)
Base.eachmatch(rs::RegexString, x) = Base.eachmatch(Regex(rs), x)

end # module
