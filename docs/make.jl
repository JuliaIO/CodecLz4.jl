using Documenter, CodecLz4

makedocs(;
    modules=[CodecLz4],
    pages=[
        "Home" => "index.md",
    ],
    sitename="CodecLz4.jl",
    authors="Invenia Technical Computing Corporation",
)

deploydocs(;
    repo="github.com/JuliaIO/CodecLz4.jl",
)
