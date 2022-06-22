import PikaParser as P
using JuliaFormatter
using ReadableRegex


##

special_characters = ['\\', '.', '?', '+', '-', '[', ']', '(', ')', '|', '^', '$']
escape_invariants = ['-', '@', ':']
specializable = ['d', 'w']

specializable = Dict(
    'w' => :WORD,
    'W' => :NON_WORD,
    'd' => :DIGIT,
    'D' => :NON_DIGIT,
    's' => :WHITESPACE,
    'S' => :NON_WHITESPACE,
    'b' => :WORDBOUND,
    'B' => :NON_WORDBOUND,
)

rules = Dict(
    :char => P.satisfy(x -> x ∉ special_characters),
    :digit => P.satisfy(x -> x in '0':'9'),
    :integer => P.one_or_more(:digit),
    :special_char => P.satisfy(x -> x in special_characters),
    :escape_invariant_char => P.satisfy(x -> x in escape_invariants),
    :normalizable_char => P.first(:special_char, :escape_invariant_char),
    :backslash => P.token('\\'),
    :normalized_char => P.seq(:backslash, :normalizable_char),
    :specializable_char => P.satisfy(x -> haskey(specializable, x)),
    :specialized_char => P.seq(:backslash, :specializable_char),
    :unescaped_setchar => P.satisfy(x -> x ∉ ['\\', '-', ']']),
    :setchar => P.first(:specialized_char, :normalized_char, :unescaped_setchar),
    :set_range_char => P.token('-'),
    :setcharrange => P.seq(
        :setchar,
        :set_range_char,
        :setchar
    ),
    :setcontent => P.first(:setcharrange, :setchar),
    :setcontents => P.zero_or_more(:setcontent),
    :set_open_char => P.token('['),
    :set_close_char => P.token(']'),
    :set_not_char => P.token('^'),
    :set => P.seq(
        :set_open_char,
        :setcontents,
        :set_close_char,
    ),
    :not_set => P.seq(
        :set_open_char,
        :set_not_char,
        :setcontents,
        :set_close_char,
    ),
    :sequence => P.one_or_more(:expr),
    :expr => P.first(:negative_lookahead, :positive_lookahead, :positive_lookbehind, :negative_lookbehind, :zero_or_more, :one_or_more, :repetition, :repetition_at_least, :repetition_from_to, :maybe, :noncapturing_group, :capturing_group, :not_set, :set, :either, :specialized_char, :dot, :normalized_char, :char, :_begin, :_end),
    :question_mark => P.token('?'),
    :maybe => P.seq(:expr, :question_mark),
    :plus => P.token('+'),
    :one_or_more => P.seq(:expr, :plus),
    :times => P.token('*'),
    :zero_or_more => P.seq(:expr, :times),
    :opening_curly => P.token('{'),
    :closing_curly => P.token('}'),
    :opening_paren => P.token('('),
    :closing_paren => P.token(')'),
    :colon => P.token(':'),
    :repetition => P.seq(:expr, :opening_curly, :integer, :closing_curly),
    :repetition_at_least => P.seq(:expr, :opening_curly, :integer, :comma, :closing_curly),
    :repetition_from_to => P.seq(:expr, :opening_curly, :integer, :comma, :integer, :closing_curly),
    :noncapturing_group => P.seq(:opening_paren, :question_mark, :colon, :sequence, :closing_paren),
    :capturing_group => P.seq(:opening_paren, :sequence, :closing_paren),
    :comma => P.token(','),
    :pipe => P.token('|'),
    :either => P.seq(:sequence, :pipe, :sequence),
    :_begin => P.token('^'),
    :_end => P.token('$'),
    :dot => P.token('.'),
    :bang => P.token('!'),
    :equal => P.token('='),
    :negative_lookahead => P.seq(:expr, :opening_paren, :question_mark, :bang, :sequence, :closing_paren),
    :positive_lookahead => P.seq(:expr, :opening_paren, :question_mark, :equal, :sequence, :closing_paren),
    :less => P.token('<'),
    :positive_lookbehind => P.seq(:opening_paren, :question_mark, :less, :equal, :sequence, :closing_paren, :expr),
    :negative_lookbehind => P.seq(:opening_paren, :question_mark, :less, :bang, :sequence, :closing_paren, :expr),
)

g = P.make_grammar(
    [:sequence], # the top-level rule
    P.flatten(rules),
)

function print_formatted(expr)
    io = IOBuffer()
    Base.show_unquoted(io, expr)
    println(format_text(String(take!(io))))
    return
end

function explain_regex(reg::Regex)
    input = collect(reg.pattern)
    p = P.parse(g, input)

    i = P.find_match_at(g, p, :sequence, 1)
    print_formatted(P.traverse_match(g, p, i, :sequence))

    expr = P.traverse_match(g, p, i, :sequence,
        fold = function(rule, match, subvals)
            rule == :sequence ? (length(subvals) == 1 ? only(subvals) : Expr(:call, :*, subvals...)) :
            rule == :char ? only(input[match.pos:match.pos+match.len-1]) :
            rule == :special_char ? only(input[match.pos:match.pos+match.len-1]) :
            rule == :escape_invariant_char ? only(input[match.pos:match.pos+match.len-1]) :
            rule == :normalizable_char ? only(input[match.pos:match.pos+match.len-1]) :
            rule == :normalized_char ? subvals[2] :
            rule == :specializable_char ? only(input[match.pos:match.pos+match.len-1]) :
            rule == :specialized_char ? specializable[subvals[2]] :
            rule == :unescaped_setchar ? only(input[match.pos:match.pos+match.len-1]) :
            rule == :setchar ? subvals[1] :
            rule == :expr ? subvals[1] :
            rule == :chunk ? subvals[1] :
            rule == :set ? Expr(:call, :char_in, subvals[2]...) :
            rule == :not_set ? Expr(:call, :char_not_in, subvals[3]...) :
            rule == :setexpr ? subvals[1] :
            rule == :setcontent ? subvals[1] :
            rule == :setcontents ? subvals :
            rule == :setcharrange ? (subvals[1]:subvals[3]) :
            rule == :maybe ? Expr(:call, :maybe, subvals[1]) :
            rule == :one_or_more ? Expr(:call, :one_or_more, subvals[1]) :
            rule == :zero_or_more ? Expr(:call, :zero_or_more, subvals[1]) :
            rule == :repetition ? Expr(:call, :exactly, subvals[3], subvals[1]) :
            rule == :repetition_at_least ? Expr(:call, :at_least, subvals[3], subvals[1]) :
            rule == :repetition_from_to ? Expr(:call, :between, subvals[3], subvals[5], subvals[1]) :
            rule == :integer ? parse(Int, String(input[match.pos:match.pos+match.len-1])) :
            rule == :noncapturing_group ? subvals[4] :
            rule == :capturing_group ? Expr(:call, :capture, subvals[2]) :
            rule == :either ? collapse_either(subvals[1], subvals[3]) :
            rule == :_begin ? :BEGIN :
            rule == :_end ? :END :
            rule == :dot ? :NON_LINEBREAK :
            rule == :negative_lookahead ? :(look_for($(subvals[1]), not_before = $(subvals[5]))) :
            rule == :positive_lookahead ? :(look_for($(subvals[1]), before = $(subvals[5]))) :
            rule == :positive_lookbehind ? :(look_for($(subvals[7]), after = $(subvals[5]))) :
            rule == :negative_lookbehind ? :(look_for($(subvals[7]), not_after = $(subvals[5]))) :
            nothing
    end)

    println("Regex ", reg.pattern)
    print_formatted(expr)
end

function collapse_either(a, b)
    if b isa Expr && b.head == :call && b.args[1] == :either
        Expr(:call, :either, a, b.args[2:end]...)
    else
        Expr(:call, :either, a, b)
    end
end

explain_regex(r"hi+[^a-z]\??")
explain_regex(r"hi+[^a-z]{8}")
explain_regex(r"hi+[^a-z]{8,}")
explain_regex(r"hi+[^a-z]{8,10}")
explain_regex(r"(?:x?)")
explain_regex(r"(?:hi+[^a-z]){8,10}")
explain_regex(r"(?:(?:x))")
explain_regex(r"hiy*(aa?)")
explain_regex(r"a|bce")
explain_regex(r"a|b|c|d")
explain_regex(r"a|b|cde|d")
explain_regex(r"[1-9]\d\w\W{0,2}")
explain_regex(r"^[1-9]$")
explain_regex(r".?")

explain_regex(r"^(\$\\)?")

explain_regex(r"(?<!a)b")
explain_regex(r"(?<=a)b")
explain_regex(r"a(?!b)")
explain_regex(r"a(?=b)")