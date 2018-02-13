__precompile__()
module LZ4


depsjl = joinpath(dirname(@__FILE__), "..", "deps", "deps.jl")
if isfile(depsjl)
    include(depsjl)
else
    error("LZ4 not properly installed. Please run Pkg.build(\"LZ4\") and restart julia")
end

export LZ4Compressor, LZ4CompressorStream
export LZ4Decompressor, LZ4DecompressorStream

import TranscodingStreams:
    TranscodingStreams,
    TranscodingStream,
    Memory,
    Error

include("lz4frame.jl")
include("stream_compression.jl")

end
