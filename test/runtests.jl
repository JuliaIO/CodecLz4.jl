using LZ4
using Base.Test

@testset "LZ4.jl" begin
	include("lz4.jl")
	include("lz4framed.jl")

end
