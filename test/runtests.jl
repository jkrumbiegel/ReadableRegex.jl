using ReadableRegex
using Test

@testset "ReadableRegex.jl" begin

    str1 = "Main Street 28"
    str2 = "Another Road 371"
    str3 = " Another Road 371"
    str4 = "Another Road 371a"
    str5 = "Another Road 371 "

    r = BEGIN * at_least_one(WORD) *
            any_of(WHITESPACE * at_least_one(WORD)) *
            WHITESPACE * at_least_one(DIGIT) * END

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
    @test match(matchonly(at_least_one(DIGIT) , before = " for me"), str2).match == "123"

    str3 = "a2 3"
    @test match(matchonly(DIGIT, not_after = WORD), str3).match == "3"
end

@testset "Numbers" begin
    str = "1 2.0 .3 -.4 -5 60 700 800.9 +9000"

    matches = eachmatch(
        maybe(["-", "+"]) * maybe(any_of(DIGIT) * ".") * at_least_one(DIGIT),
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