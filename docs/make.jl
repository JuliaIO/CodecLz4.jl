using Documenter, CodecLz4

makedocs(;
    modules=[CodecLz4],
    format=Documenter.HTML(),
    pages=[
        "Home" => "index.md",
    ],
    repo="https://github.com/invenia/CodecLz4.jl/blob/{commit}{path}#L{line}",
    sitename="CodecLz4.jl",
    authors="Invenia Technical Computing Corporation",
)

deploydocs(;
    repo="github.com/invenia/CodecLz4.jl",
    target="build",
    deps=nothing,
    make=nothing,
)
