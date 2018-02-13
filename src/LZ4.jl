__precompile__()
module LZ4

using TranscodingStreams: TranscodingStreams, TranscodingStream, Memory, Error

export LZ4Compressor, LZ4CompressorStream, LZ4Decompressor, LZ4DecompressorStream

depsjl = joinpath(@__DIR__, "..", "deps", "deps.jl")
if isfile(depsjl)
    include(depsjl)
else
    error("LZ4 not properly installed. Please run Pkg.build(\"LZ4\") and restart julia")
end

include("lz4frame.jl")
include("stream_compression.jl")

end
