using Documenter, LZ4

makedocs(;
    modules=[LZ4],
    format=:html,
    pages=[
        "Home" => "index.md",
    ],
    repo="https://github.com/morris25/LZ4.jl/blob/{commit}{path}#L{line}",
    sitename="LZ4.jl",
    authors="Invenia Technical Computing Corporation",
    assets=[],
)

deploydocs(;
    repo="github.com/morris25/LZ4.jl",
    target="build",
    julia="0.6",
    deps=nothing,
    make=nothing,
)
