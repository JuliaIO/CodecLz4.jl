__precompile__()
module LZ4

depsjl = joinpath(dirname(@__FILE__), "..", "deps", "deps.jl")
if isfile(depsjl)
    include(depsjl)
else
    error("LZ4 not properly installed. Please run Pkg.build(\"LZ4\") and restart julia")
end

export compress_stream, decompress_stream

#include("orig_lz4.jl")
#include("lz4hc.jl")
#include("lz4frame.jl")
#include("lz4frame_static.jl")

include("stream_compression.jl")

end
