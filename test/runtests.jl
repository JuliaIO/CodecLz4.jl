using CodecLz4
using Test

@testset "CodecLz4.jl" begin
    include("gcsafe_ccall.jl")
    include("runtime_compatibility.jl")
    include("headers/lz4.jl")
    include("headers/lz4frame.jl")
    include("headers/lz4hc.jl")
    include("frame_compression.jl")
    include("hc_compression.jl")
    include("lz4_compression.jl")
    include("simple_compression.jl")
    @testset "Native buffer lifetime" begin
        project = dirname(Base.active_project())
        script = joinpath(@__DIR__, "buffer_lifetime.jl")
        @test success(`$(Base.julia_cmd()) --project=$project $script`)
    end
end
