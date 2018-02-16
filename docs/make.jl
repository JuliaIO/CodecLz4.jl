using Documenter, CodecLz4

makedocs(;
    modules=[CodecLz4],
    format=:html,
    pages=[
        "Home" => "index.md",
    ],
    repo="https://github.com/invenia/CodecLz4.jl/blob/{commit}{path}#L{line}",
    sitename="CodecLz4.jl",
    authors="Invenia Technical Computing Corporation",
    assets=[],
)

deploydocs(;
    repo="github.com/invenia/CodecLz4.jl",
    target="build",
    julia="0.6",
    deps=nothing,
    make=nothing,
)
