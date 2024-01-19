using CodecLz4
using Random
using Test

@testset "CodecLz4.jl" begin
    include("headers/lz4.jl")
    include("headers/lz4frame.jl")
    include("headers/lz4hc.jl")
    include("frame_compression.jl")
    include("hc_compression.jl")
    include("lz4_compression.jl")
    include("simple_compression.jl")
end
