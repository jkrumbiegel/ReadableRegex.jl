import PikaParser as P
using JuliaFormatter


##

rules = Dict(
    # match a sequence of characters that satisfies `isdigit`
    # :digits => P.one_or_more(:digit => P.satisfy(isdigit)),
    :char => P.satisfy(x -> x ∉ ['\\', '?', '+', '-', '[', ']', '(', ')']),
    :setchar => P.satisfy(x -> x ∉ ['\\', '-', ']']),
    :setcharrange => P.seq(
        :setchar,
        P.token('-'),
        :setchar
    ),
    :setcontent => P.first(:setcharrange, :setchar),
    :setcontents => P.zero_or_more(:setcontent),
    :set => P.seq(
        P.token('['),
        :setcontents,
        P.token(']')
    ),
    :not_set => P.seq(
        P.token('['),
        P.token('^'),
        :setcontents,
        P.token(']')
    ),
    :expr => P.first(:maybe, :not_set, :set, :char),
    :regex => P.one_or_more(:expr),
    :maybe => P.seq(:expr, P.token('?')),
)

g = P.make_grammar(
    [:regex], # the top-level rule
    P.flatten(rules),
)

function print_formatted(expr)
    io = IOBuffer()
    Base.show_unquoted(io, expr)
    print(format_text(String(take!(io))))
    return
end

function explain_regex(reg::Regex)
    input = collect(reg.pattern)
    p = P.parse(g, input)

    print_formatted(P.traverse_match(g, p, P.find_match_at(g, p, :regex, 1), :regex))

    expr = P.traverse_match(g, p, P.find_match_at(g, p, :regex, 1), :regex,
        fold = function(rule, match, subvals)
            rule == :regex ? Expr(:call, :*, subvals...) :
            rule == :char ? only(input[match.pos:match.pos+match.len-1]) :
            rule == :setchar ? only(input[match.pos:match.pos+match.len-1]) :
            rule == :expr ? subvals[1] :
            rule == :chunk ? subvals[1] :
            rule == :set ? Expr(:call, :char_in, subvals[2]...) :
            rule == :not_set ? Expr(:call, :char_not_in, subvals[3]...) :
            rule == :setexpr ? subvals[1] :
            rule == :setcontent ? subvals[1] :
            rule == :setcontents ? subvals :
            rule == :setcharrange ? (subvals[1]:subvals[3]) :
            rule == :string ? String(input[match.pos:match.pos+match.len-1]) :
            rule == :maybe ? Expr(:call, :maybe, subvals[1]) :
            nothing
    end)

    println("Regex ", reg.pattern)
    print_formatted(expr)
end

explain_regex(r"hi[a-z]?")
explain_regex(r"hiyaa?")