__precompile__()
module CodecLz4
using Compat
using TranscodingStreams: TranscodingStream, Memory, Error
using TranscodingStreams
export LZ4Compressor, LZ4CompressorStream,
    LZ4Decompressor, LZ4DecompressorStream,
    BlockSizeID, default_size, max64KB, max256KB, max1MB, max4MB,
    BlockMode, block_linked, block_independent,
    FrameType, normal_frame, skippable_frame

depsjl = joinpath(@__DIR__, "..", "deps", "deps.jl")
if isfile(depsjl)
    include(depsjl)
else
    error("CodecLz4 not properly installed. Please run Pkg.build(\"CodecLz4\") and restart julia")
end

struct LZ4Exception <: Exception
    src::AbstractString
    msg::AbstractString
end

function Base.showerror(io::IO, ex::LZ4Exception, bt; backtrace=false)
    printstyled(io, "$(ex.src): $(ex.msg)", color=Base.error_color())
end

include("lz4frame.jl")
include("stream_compression.jl")

end
