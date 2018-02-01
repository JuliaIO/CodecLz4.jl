depsjl = joinpath(dirname(@__FILE__), "..", "deps", "deps.jl")
if isfile(depsjl)
    include(depsjl)
else
    error("LZ4 not properly installed. Please run Pkg.build(\"LZ4\") and restart julia")
end

include("../src/lz4frame.jl")

@testset "C interface" begin
    include("lz4.jl")
    include("lz4frame.jl")
end