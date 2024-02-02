using TranscodingStreams: splitkwargs

const BUF_SIZE = 16*1024
const LZ4_FOOTER_SIZE = 4

mutable struct LZ4FrameCompressor <: TranscodingStreams.Codec
    ctx::Ptr{LZ4F_cctx}
    prefs::Base.RefValue{LZ4F_preferences_t}
    header::Vector{UInt8}
    write_header::Bool
end

"""
    LZ4FrameCompressor(; kwargs...)

Creates an LZ4 compression codec.

# Keywords
- `blocksizeid::BlockSizeID=default_size`: `max64KB`, `max256KB`, `max1MB`, or `max4MB` or `default_size`
- `blockmode::BlockMode=block_linked`:  `block_linked` or `block_independent`
- `contentchecksum::Bool=false`: if `true`, frame is terminated with a
    32-bits checksum of decompressed data
- `frametype::FrameType=normal_frame)`:  `normal_frame` or `skippable_frame`
- `contentsize::Integer=0`: Size of uncompressed content (0 for unknown)
- `blockchecksum::Bool=false`: if `true`, each block is followed by a
    checksum of block's compressed data
- `compressionlevel::Integer=0`: compression level (-1..12)
- `autoflush::Bool=false`: always flush if `true`
"""
function LZ4FrameCompressor(; kwargs...)
    x, y = splitkwargs(kwargs, (:compressionlevel, :autoflush))
    ctx = Ptr{LZ4F_cctx}(C_NULL)
    frame = LZ4F_frameInfo_t(; y...)
    prefs = Ref(LZ4F_preferences_t(frame; x...))
    return LZ4FrameCompressor(ctx, prefs, Vector{UInt8}(undef, LZ4F_HEADER_SIZE_MAX), false)
end

const LZ4FrameCompressorStream{S} = TranscodingStream{LZ4FrameCompressor,S} where S<:IO

"""
    LZ4FrameCompressorStream(stream::IO; kwargs...)

Creates an LZ4 compression stream. See `LZ4FrameCompressor()` and `TranscodingStream()` for arguments.
"""
function LZ4FrameCompressorStream(stream::IO; kwargs...)
    x, y = splitkwargs(kwargs, (:blocksizeid, :blockmode, :contentchecksum, :blockchecksum, :frametype, :contentsize, :compressionlevel, :autoflush))
    return TranscodingStream(LZ4FrameCompressor(; x...), stream; y...)
end

"""
    TranscodingStreams.expectedsize(codec::LZ4FrameCompressor, input::Memory)

Returns the expected size of the transcoded data.
"""
function TranscodingStreams.expectedsize(codec::LZ4FrameCompressor, input::Memory)::Int
    LZ4F_compressBound(length(input), codec.prefs) + LZ4F_HEADER_SIZE_MAX + LZ4_FOOTER_SIZE
end

"""
   TranscodingStreams.minoutsize(codec::LZ4FrameCompressor, input::Memory)

Returns the minimum output size of `process`.
"""
function TranscodingStreams.minoutsize(codec::LZ4FrameCompressor, input::Memory)::Int
    LZ4F_compressBound(length(input), codec.prefs)
end

"""
   TranscodingStreams.initialize(codec::LZ4FrameCompressor)

Initializes the LZ4F Compression Codec.
"""
function TranscodingStreams.initialize(codec::LZ4FrameCompressor)::Nothing
    cctxPtr = Ref{Ptr{LZ4F_cctx}}(C_NULL)
    LZ4F_createCompressionContext(cctxPtr, LZ4F_getVersion())
    codec.ctx = cctxPtr[]
    nothing
end

"""
    TranscodingStreams.finalize(codec::LZ4FrameCompressor)

Finalizes the LZ4F Compression Codec.
"""
function TranscodingStreams.finalize(codec::LZ4FrameCompressor)::Nothing
    LZ4F_freeCompressionContext(codec.ctx)
    codec.ctx = C_NULL
    nothing
end

"""
    TranscodingStreams.startproc(codec::LZ4FrameCompressor, mode::Symbol, error::Error)

Starts processing with the codec
Creates the LZ4F header to be written to the output.
"""
function TranscodingStreams.startproc(codec::LZ4FrameCompressor, mode::Symbol, error::Error)::Symbol
    try
        header = codec.header
        resize!(header, LZ4F_HEADER_SIZE_MAX)
        headerSize = LZ4F_compressBegin(codec.ctx, header, convert(Csize_t, sizeof(header)), codec.prefs)
        resize!(header, headerSize)
        codec.write_header = true
        :ok
    catch err
        error[] = err
        :error
    end
end

"""
    TranscodingStreams.process(codec::LZ4FrameCompressor, input::Memory, output::Memory, error::Error)

Compresses the data from `input` and writes to `output`.
The LZ4 compression algorithm may simply buffer the input data a full frame can be produced, so `data_written` may be 0.
`flush()` may be used to force `output` to be written.
"""
function TranscodingStreams.process(codec::LZ4FrameCompressor, input::Memory, output::Memory, error::Error)::Tuple{Int,Int,Symbol}
    data_read = 0
    data_written = 0
    if codec.write_header
        if length(output) < sizeof(codec.header)
            error[] = ErrorException("Output buffer too small for header.")
            return (data_read, data_written, :error)
        end
        data_written = sizeof(codec.header)
        GC.@preserve codec unsafe_copyto!(output.ptr, pointer(codec.header), data_written)
        codec.write_header = false
    end

    data_read = length(input)
    try
        if data_read == 0
            data_written += LZ4F_compressEnd(codec.ctx, output.ptr + data_written, length(output) - data_written, C_NULL)
            (data_read, data_written, :end)
        else
            data_written += LZ4F_compressUpdate(codec.ctx, output.ptr + data_written, length(output) - data_written, input.ptr, data_read, C_NULL)
            (data_read, data_written, :ok)
        end

    catch err
        error[] = err
        data_read = 0
        (data_read, data_written, :error)
    end

end

mutable struct LZ4FrameDecompressor <: TranscodingStreams.Codec
    dctx::Ptr{LZ4F_dctx}
end

"""
    LZ4FrameCompressor()

Creates an LZ4 decompression codec.
"""
function LZ4FrameDecompressor()
    dctx = Ptr{LZ4F_dctx}(C_NULL)
    return LZ4FrameDecompressor(dctx)
end

const LZ4FrameDecompressorStream{S} = TranscodingStream{LZ4FrameDecompressor,S} where S<:IO

"""
    LZ4FrameCompressorStream(stream::IO; kwargs...)

Creates an LZ4 decompression stream. See `TranscodingStream()` for arguments.
"""
function LZ4FrameDecompressorStream(stream::IO; kwargs...)
    return TranscodingStream(LZ4FrameDecompressor(), stream; kwargs...)
end

"""
    TranscodingStreams.initialize(codec::LZ4FrameDecompressor)

Initializes the LZ4F Decompression Codec.
"""
function TranscodingStreams.initialize(codec::LZ4FrameDecompressor)::Nothing
    dctxPtr = Ref{Ptr{LZ4F_dctx}}(C_NULL)
    LZ4F_createDecompressionContext(dctxPtr, LZ4F_getVersion())
    codec.dctx = dctxPtr[]
    nothing
end

"""
    TranscodingStreams.finalize(codec::LZ4FrameDecompressor)

Finalizes the LZ4F Decompression Codec.
"""
function TranscodingStreams.finalize(codec::LZ4FrameDecompressor)::Nothing
    LZ4F_freeDecompressionContext(codec.dctx)
    codec.dctx = C_NULL
    nothing
end

"""
    TranscodingStreams.process(codec::LZ4FrameDecompressor, input::Memory, output::Memory, error::Error)

Decompresses the data from `input` and writes to `output`.
If the input data is not properly formatted this function will throw an error.
"""
function TranscodingStreams.process(codec::LZ4FrameDecompressor, input::Memory, output::Memory, error::Error)::Tuple{Int,Int,Symbol}
    data_read = 0
    data_written = 0

    try
        if length(input) == 0
            (data_read, data_written, :end)
        else
            src_size = Ref{Csize_t}(length(input))
            dst_size = Ref{Csize_t}(length(output))
            LZ4F_decompress(codec.dctx, output.ptr, dst_size, input.ptr, src_size, C_NULL)
            (src_size[], dst_size[], :ok)
        end
    catch err
        if isa(err, LZ4Exception) && err.msg == "ERROR_frameType_unknown"
            codec.dctx = C_NULL
        end
        error[] = err
        (data_read, data_written, :error)
    end

end
