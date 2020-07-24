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

    @test match(matchonly(DIGIT, after = WORD), str).match == "3"
    @test match(matchonly(DIGIT, not_before = WORD), str).match == "2"

    str2 = "123 for me, 456 for you"
    @test match(matchonly(one_or_more(DIGIT) , before = " for me"), str2).match == "123"

    str3 = "a2 3"
    @test match(matchonly(DIGIT, not_after = WORD), str3).match == "3"
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
    reg = "p" * capture(chars("aeiou")) * "st" * reference(1)
    @test match(reg, str).match == "pasta"

    reg2 = "p" * capture(chars("aeiou"), as = "vowel") * "st" * reference("vowel")
    @test match(reg, str).match == "pasta"
end

@testset "Unicode categories" begin
    str = "how is Jim doing?"
    @test match(UPPERCASE, str).match == "J"
    @test match(PUNCTUATION, str).match == "?"
end

@testset "multiarg chars" begin
    str = "hakuna matata"

    reg = at_least(2, chars("mat"))
    @test match(reg, str).match == "matata"

    reg2 = one_or_more(chars('h':'n', 'a', 'u'))
    @test match(reg2, str).match == "hakuna"

    reg3 = at_least(2, not_chars(WHITESPACE, 'a'))
    @test match(reg3, str).match == "kun"
end