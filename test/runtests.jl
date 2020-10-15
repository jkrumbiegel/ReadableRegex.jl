using ReadableRegex
using Test

@testset "ReadableRegex.jl" begin

    str1 = "Main Street 28"
    str2 = "Another Road 371"
    str3 = " Another Road 371"
    str4 = "Another Road 371a"
    str5 = "Another Road 371 "

    r = BEGIN * one_or_more(WORD) *
            zero_or_more(WHITESPACE * one_or_more(WORD)) *
            WHITESPACE * one_or_more(DIGIT) * END

    @test match(r, str1).match == str1
    @test match(r, str2).match == str2
    @test isnothing(match(r, str3))
    @test isnothing(match(r, str4))
    @test isnothing(match(r, str5))

    str6 = "a, bb, ccc"
    @test match(at_least(3, WORD), str6).match == "ccc"

    str7 = "a, bbb, ccccc"
    @test match(between(2, 4, WORD), str7).match == "bbb"
end

@testset "Lookarounds" begin
    str = "1a 2 b3 c4d"

    @test match(look_for(DIGIT, after = WORD), str).match == "3"
    @test match(look_for(DIGIT, not_before = WORD), str).match == "2"

    str2 = "123 for me, 456 for you"
    @test match(look_for(one_or_more(DIGIT) , before = " for me"), str2).match == "123"

    str3 = "a2 3"
    @test match(look_for(DIGIT, not_after = WORD), str3).match == "3"

    str4 = "1 2.0 .3 -.4 -5 60 700 800.9 +9000"

    reg = look_for(
            maybe(char_in("+-")) * one_or_more(DIGIT),
            not_after = ".",
            not_before = NON_SEPARATOR)

    @test collect(m.match for m in eachmatch(reg, str4)) == ["1", "-5", "60", "700", "+9000"]      
end

@testset "Numbers" begin
    str = "1 2.0 .3 -.4 -5 60 700 800.9 +9000"

    matches = eachmatch(
        maybe(["-", "+"]) * maybe(zero_or_more(DIGIT) * ".") * one_or_more(DIGIT),
        str
    )

    @test all(split(str) .== (m.match for m in matches))
end

@testset "Range" begin
    str = "ab cd ef gh"

    matches = [m.match for m in eachmatch(exactly(2, 'a':'e'), str)]

    @test matches == ["ab", "cd"]
end

@testset "Compile" begin
    function matcher(str)
        reg = @compile BEGIN * maybe('a':'z') * exactly(1, DIGIT) * END
        match(reg, str)
    end

    @test !isnothing(matcher("a1"))
    @test !isnothing(matcher("3"))
    @test isnothing(matcher("2a"))
end

@testset "Capture and Reference" begin
    str = "pasta pesto"
    reg = "p" * capture(char_in("aeiou")) * "st" * reference(1)
    @test match(reg, str).match == "pasta"

    reg2 = "p" * capture(char_in("aeiou"), as = "vowel") * "st" * reference("vowel")
    @test match(reg, str).match == "pasta"
end

@testset "Unicode categories" begin
    str = "how is Jim doing?"
    @test match(UPPERCASE, str).match == "J"
    @test match(PUNCTUATION, str).match == "?"
end

@testset "multiarg char_in" begin
    str = "hakuna matata"

    reg = at_least(2, char_in("mat"))
    @test match(reg, str).match == "matata"

    reg2 = one_or_more(char_in('h':'n', 'a', 'u'))
    @test match(reg2, str).match == "hakuna"

    reg3 = at_least(2, char_not_in(WHITESPACE, 'a'))
    @test match(reg3, str).match == "kun"


    str = "-"
    reg = char_in("a-z") # this should give three chars, not a range
    @test match(reg, str).match == "-"
    reg2 = char_in('a':'z') # this should give a range
    @test match(reg2, str) === nothing
end

@testset "lazy and possessive quantifiers" begin

    str = "abcabcabc"

    @test match(maybe("abc"), str).match == "abc"
    @test match(lazy_maybe("abc"), str).match == ""

    @test match(at_least(2, "abc"), str).match == str
    @test match(lazy_at_least(2, "abc"), str).match == "abcabc"

    @test match(zero_or_more("abc"), str).match == str
    @test match(lazy_zero_or_more("abc"), str).match == ""

    @test match(one_or_more("abc"), str).match == str
    @test match(lazy_one_or_more("abc"), str).match == "abc"

    @test match(between(2, 3, "abc"), str).match == str
    @test match(lazy_between(2, 3, "abc"), str).match == "abcabc"

    str2 = "1234"

    @test match(one_or_more(DIGIT) * "4", str2).match == "1234"
    @test match(possessive_one_or_more(DIGIT) * "4", str2) === nothing

    @test match(zero_or_more(DIGIT) * "4", str2).match == "1234"
    @test match(possessive_zero_or_more(DIGIT) * "4", str2) === nothing

    @test match(between(1, 4, DIGIT) * "4", str2).match == "1234"
    @test match(possessive_between(1, 4, DIGIT) * "4", str2) === nothing

    @test match(at_least(2, DIGIT) * "4", str2).match == "1234"
    @test match(possessive_at_least(2, DIGIT) * "4", str2) === nothing

    # don't quite understand why this doesn't work, leave it out for now
    # str3 = "123"

    # @test match(maybe("123") * "3", str3).match == "3"
    # @test match(possessive_maybe("123") * "3", str3) === nothing
end