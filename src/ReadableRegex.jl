module ReadableRegex

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
        noncapturing_group_or_token(string) * outer
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
optional(r::RegexString) = RegexString(noncapturing_group_or_append(r.s, "?"))
any_number_of(r::RegexString) = RegexString(noncapturing_group_or_append(r.s, "*"))
followed_by(r::RegexString, by::RegexString) = RegexString(noncapturing_group_or_token(r.s) * "(?=$(by.s))")
not_followed_by(r::RegexString, by::RegexString) = RegexString(noncapturing_group_or_token(r.s) * "(?!$(by.s))")
one_of(rs::RegexString...) = RegexString((join([noncapturing_group_or_token(r.s) for r in rs], "|")))

at_least_one(x) = at_least_one(to_regexstring(x))
at_least(n::Int, x) = at_least(n, to_regexstring(x))
between(low::Int, high::Int, x) = between(low, high, to_regexstring(x))
optional(x) = optional(to_regexstring(x))
any_number_of(x) = any_number_of(to_regexstring(x))
followed_by(x, by) = followed_by(to_regexstring(x), to_regexstring(by))
not_followed_by(x, by) = not_followed_by(to_regexstring(x), to_regexstring(by))
one_of(args...) = one_of(to_regexstring.(args)...)

Base.:+(r1::RegexString, r2::RegexString) = RegexString(r1.s * r2.s)

Regex(r::RegexString) = Regex(r.s)

at_least_one("a") + optional("b") + at_least(2, "c")


str = "Main Street 28"


Base.match(rs::RegexString, x) = Base.match(Regex(rs), x)
Base.eachmatch(rs::RegexString, x) = Base.eachmatch(Regex(rs), x)
match(BEGIN + at_least_one(WORD) + any_number_of(WHITESPACE + at_least_one(WORD)) + WHITESPACE + at_least_one(DIGIT) + END, str)

match(BEGIN + at_least_one(ANY_BUT_LINEBREAK) + END, str)

match(at_least_one(DIGIT), str)

Regex(at_least_one(DIGIT))

str = "a1 b2 c3 d e5"
eachmatch(not_followed_by('a':'z', DIGIT), str) .|> println


end # module
