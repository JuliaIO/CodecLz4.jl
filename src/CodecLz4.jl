__precompile__()
module CodecLz4
using TranscodingStreams: TranscodingStream, Memory, Error
using TranscodingStreams
export LZ4FrameCompressor, LZ4FrameCompressorStream,
    LZ4FrameDecompressor, LZ4FrameDecompressorStream,
    LZ4FastCompressor, LZ4FastCompressorStream,
    LZ4SafeDecompressor, LZ4SafeDecompressorStream,
    LZ4HCCompressor, LZ4HCCompressorStream,
    BlockSizeID, default_size, max64KB, max256KB, max1MB, max4MB,
    BlockMode, block_linked, block_independent,
    FrameType, normal_frame, skippable_frame,
    lz4_compress, lz4_hc_compress, lz4_decompress


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

Base.showerror(io::IO, ex::LZ4Exception) = print(io, "$(ex.src): $(ex.msg)")

include("headers/lz4frame.jl")
include("headers/lz4.jl")
include("headers/lz4hc.jl")
include("frame_compression.jl")
include("hc_compression.jl")
include("lz4_compression.jl")
include("simple_compression.jl")

include("deprecated.jl")

end
