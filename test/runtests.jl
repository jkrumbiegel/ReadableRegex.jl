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

    reg2 = at_least_one(chars('h':'n', 'a', 'u'))
    @test match(reg2, str).match == "hakuna"

    reg3 = at_least(2, not_chars(WHITESPACE, 'a'))
    @test match(reg3, str).match == "kun"
end


@testset "urls" begin

    valid = not_chars("./ -")

    url_pattern = BEGIN *
        capture(["http" * maybe("s"), "ftp"], as = "protocol") *
        "://" *
        maybe(
            capture(at_least_one(NON_SEPARATOR), as = "username") *
            maybe(":" * capture(at_least_one(NON_SEPARATOR), as = "password")) *
            "@"
        ) *
        capture(any_of(at_least_one(valid) * maybe("-")) * at_least_one(valid), as = "host") *
        capture(any_of("." * any_of(at_least_one(valid) * maybe("-")) * at_least_one(valid)), as = "domain") *
        "." *
        capture(at_least(2, WORD), as = "TLD") *
        maybe(":" * capture(between(2, 5, DIGIT), as = "port")) *
        maybe("/" * capture(at_least_one(NON_SEPARATOR), as = "resource")) *
        END |> Regex

    goods = (
        "http://foo.com/blah_blah",
        "http://foo.com/blah_blah/",
        "http://foo.com/blah_blah_(wikipedia)",
        "http://foo.com/blah_blah_(wikipedia)_(again)",
        "http://www.example.com/wpstyle/?p=364",
        "https://www.example.com/foo/?bar=baz&inga=42&quux",
        "http://✪df.ws/123",
        "http://userid:password@example.com:8080",
        "http://userid:password@example.com:8080/",
        "http://userid@example.com",
        "http://userid@example.com/",
        "http://userid@example.com:8080",
        "http://userid@example.com:8080/",
        "http://userid:password@example.com",
        "http://userid:password@example.com/",
        "http://➡.ws/䨹",
        "http://⌘.ws",
        "http://⌘.ws/",
        "http://foo.com/blah_(wikipedia)#cite-1",
        "http://foo.com/blah_(wikipedia)_blah#cite-1",
        "http://foo.com/unicode_(✪)_in_parens",
        "http://foo.com/(something)?after=parens",
        "http://☺.damowmow.com/",
        "http://code.google.com/events/#&product=browser",
        "http://j.mp",
        "ftp://foo.bar/baz",
        "http://foo.bar/?q=Test%20URL-encoded%20stuff",
        "http://مثال.إختبار",
        "http://例子.测试",
        "http://-.~_!&'()*+,;=:%40:80%2f::::::@example.com",
        "http://1337.net",
        "http://a.b-c.de",
        "http://223.255.255.254"
    );

    bads = (
        "http://",
        "http://.",
        "http://..",
        "http://../",
        "http://?",
        "http://??",
        "http://??/",
        "http://#",
        "http://##",
        "http://##/",
        "http://foo.bar?q=Spaces should be encoded",
        "//",
        "//a",
        "///a",
        "///",
        "http:///a",
        "foo.com",
        "rdar://1234",
        "h://test",
        "http:// shouldfail.com",
        ":// should fail",
        "http://foo.bar/foo(bar)baz quux",
        "ftps://foo.bar/",
        "http://-error-.invalid/",
        "http://-a.b.co",
        "http://a.b-.co",
        "http://0.0.0.0",
        "http://3628126748",
        "http://.www.foo.bar/",
        "http://www.foo.bar./",
        "http://.www.foo.bar./"
    );

    for url in goods
        !occursin(url_pattern, url) && println(url)
    end

    @test all(occursin(url_pattern, url) for url in goods)
    @test !any(occursin(url_pattern, url) for url in bads)
end