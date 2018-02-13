using Base.Test
using LZ4

@testset "LZ4.jl" begin
    include("lz4frame.jl")
    include("stream_compression.jl")
end
