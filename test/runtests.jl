
using Base.Test

@testset "LZ4.jl" begin
    include("c_interface.jl")

    include("stream_compression.jl")
end
