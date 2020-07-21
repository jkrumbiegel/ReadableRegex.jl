using ReadableRegex
using Test

@testset "ReadableRegex.jl" begin

    str1 = "Main Street 28"
    str2 = "Another Road 371"
    str3 = " Another Road 371"
    str4 = "Another Road 371a"
    str5 = "Another Road 371 "

    r = BEGIN * at_least_one(WORD) *
            any_number_of(WHITESPACE * at_least_one(WORD)) *
            WHITESPACE * at_least_one(DIGIT) * END

    @test match(r, str1).match == str1
    @test match(r, str2).match == str2
    @test isnothing(match(r, str3))
    @test isnothing(match(r, str4))
    @test isnothing(match(r, str5))
end

@testset "Lookarounds" begin
    str = "1a 2 b3 c4d"

    @test match(matchonly(DIGIT, after = WORD), str).match == "3"
    @test match(matchonly(DIGIT, not_before = WORD), str).match == "2"
end

@testset "Numbers" begin
    str = "1 2.0 .3 -.4 -5 60 700 800.9 +9000"

    matches = eachmatch(
        maybe(one_out_of("-", "+")) * maybe(any_number_of(DIGIT) * ".") * at_least_one(DIGIT),
        str
    )

    @test all(split(str) .== (m.match for m in matches))
end
