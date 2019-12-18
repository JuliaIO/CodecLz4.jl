using CodecLz4
using Test

@testset "CodecLz4.jl" begin
    include("headers/lz4frame.jl")
    include("headers/lz4.jl")
    include("headers/lz4hc.jl")
    include("stream_compression.jl")
end
