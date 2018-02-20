using Compat.Test
using CodecLz4

@testset "CodecLz4.jl" begin
    include("lz4frame.jl")
    include("stream_compression.jl")
end
