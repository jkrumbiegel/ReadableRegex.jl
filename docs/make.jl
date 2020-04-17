using Documenter, ReadableRegex

makedocs(;
    modules=[ReadableRegex],
    format=Documenter.HTML(),
    pages=[
        "Home" => "index.md",
    ],
    repo="https://github.com/jkrumbiegel/ReadableRegex.jl/blob/{commit}{path}#L{line}",
    sitename="ReadableRegex.jl",
    authors="Julius Krumbiegel",
    assets=String[],
)

deploydocs(;
    repo="github.com/jkrumbiegel/ReadableRegex.jl",
)
