using CodecLz4
using Test

@testset "CodecLz4.jl" begin
    include("lz4frame.jl")
    include("stream_compression.jl")
end
