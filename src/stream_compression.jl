using TranscodingStreams

const BUF_SIZE = 16*1024
const LZ4_FOOTER_SIZE = 4

# borrowed from CodecZlib.jl
function splitkwargs(kwargs, keys)
    hits = []
    others = []
    for kwarg in kwargs
        push!(kwarg[1] ∈ keys ? hits : others, kwarg)
    end
    return hits, others
end

mutable struct LZ4Compressor <: TranscodingStreams.Codec
    ctx::Ref{Ptr{LZ4F_cctx}}
    prefs::Ref{LZ4F_preferences_t}
    header::Memory
    write_header::Bool
end

"""
    LZ4Compressor(; kwargs...)

Creates an LZ4 compression codec.

# Keywords
- `blocksizeid::UInt32=$(LZ4F_default)`: max64KB, max256KB, max1MB, or max4MB (4..7) (0 for default)
- `blockmodeCuint=$(LZ4F_blockLinked)`:  0 for LZ4F_blockLinked or 1 for LZ4F_blockIndependent
- `contentchecksumflag::Cuint=$(LZ4F_noContentChecksum)`: if 1, frame is terminated with a
    32-bits checksum of decompressed data (0..1)
- `frametype::Cuint=$(LZ4F_frame)`:  0 for LZ4F_frame or 1 for LZ4F_skippableFrame
- `contentsize::Culonglong=0`: Size of uncompressed content (0 for unknown)
- `blockchecksumflag::Cuint=$(LZ4F_noBlockChecksum)`: if 1, each block is followed by a
    checksum of block's compressed data (0..1)
- `compressionlevel::Cint=0`: compression level (-1..12)
- `autoflush::Cuint=0`: 1 == always flush (0..1)
"""
function LZ4Compressor(; kwargs...)
    x, y = splitkwargs(kwargs, (:compressionlevel, :autoflush))

    ctx = Ref{Ptr{LZ4F_cctx}}(C_NULL)
    frame = LZ4F_frameInfo_t(; y...)
    prefs = Ref(LZ4F_preferences_t(frame; x...))
    return LZ4Compressor(ctx, prefs, Memory(Vector{UInt8}(LZ4F_HEADER_SIZE_MAX)), false)
end

const LZ4CompressorStream{S} = TranscodingStream{LZ4Compressor,S} where S<:IO

"""
    LZ4CompressorStream(stream::IO; kwargs...)

Creates an LZ4 compression stream. See `LZ4Compressor()` and `TranscodingStream()` for arguments.
"""
function LZ4CompressorStream(stream::IO; kwargs...)
    x, y = splitkwargs(kwargs, (:blocksizeid, :blockmode, :contentchecksumflag, :blockchecksumflag, :frametype, :contentsize, :compressionlevel, :autoflush))
    return TranscodingStream(LZ4Compressor(; x...), stream; y...)
end

"""
Returns the expected size of the transcoded data.
"""
function TranscodingStreams.expectedsize(codec::LZ4Compressor, input::Memory)::Int
    LZ4F_compressBound(input.size, codec.prefs) + LZ4F_HEADER_SIZE_MAX + LZ4_FOOTER_SIZE
end

"""
Returns the minimum output size of `process`.
"""
function TranscodingStreams.minoutsize(codec::LZ4Compressor, input::Memory)::Int
    LZ4F_HEADER_SIZE_MAX
end

"""
Initializes the LZ4F Compression Codec.
"""
function TranscodingStreams.initialize(codec::LZ4Compressor)::Void
    LZ4F_createCompressionContext(codec.ctx, LZ4F_getVersion())
    nothing
end

"""
Finalizes the LZ4F Compression Codec.
"""
function TranscodingStreams.finalize(codec::LZ4Compressor)::Void
    LZ4F_freeCompressionContext(codec.ctx[])
    nothing
end

"""
Starts processing with the codec
Creates the LZ4F header to be written to the output.
"""
function TranscodingStreams.startproc(codec::LZ4Compressor, mode::Symbol, error::Error)::Symbol
    try
        header = Vector{UInt8}(LZ4F_HEADER_SIZE_MAX)
        headerSize = LZ4F_compressBegin(codec.ctx[], header, convert(Csize_t, LZ4F_HEADER_SIZE_MAX), codec.prefs)
        codec.header = Memory(resize!(header, headerSize))
        codec.write_header = true
        :ok
    catch err
        error[] = err
        :error
    end
end

"""
Compresses the data from `input` and writes to `output`.
The LZ4 compression algorithm may simply buffer the input data a full frame can be produced, so `data_written` may be 0.
`flush()` may be used to force `output` to be written.
"""
function TranscodingStreams.process(codec::LZ4Compressor, input::Memory, output::Memory, error::Error)::Tuple{Int,Int,Symbol}
    data_read = 0
    data_written = 0
    if codec.write_header
        if output.size < codec.header.size
            error[] = ErrorException("Output buffer too small for header.")
            return (data_read, data_written, :error)
        end
        unsafe_copy!(output.ptr, codec.header.ptr, codec.header.size)
        data_written = codec.header.size
        codec.write_header = false
    end

    try
        if input.size == 0
            data_written += LZ4F_compressEnd(codec.ctx[], output.ptr + data_written, output.size - data_written, C_NULL)
            (data_read, data_written, :end)
        else
            data_written += LZ4F_compressUpdate(codec.ctx[], output.ptr + data_written, output.size - data_written, input.ptr, input.size, C_NULL)
            (input.size, data_written, :ok)
        end

    catch err
        error[] = err
        (data_read, data_written, :error)
    end

end

struct LZ4Decompressor <: TranscodingStreams.Codec
    dctx::Ref{Ptr{LZ4F_dctx}}
end

"""
    LZ4Compressor()

Creates an LZ4 decompression codec.
"""
function LZ4Decompressor()
    dctx = Ref{Ptr{LZ4F_dctx}}(C_NULL)
    return LZ4Decompressor(dctx)
end

const LZ4DecompressorStream{S} = TranscodingStream{LZ4Decompressor,S} where S<:IO

"""
    LZ4CompressorStream(stream::IO; kwargs...)

Creates an LZ4 decompression stream. See `TranscodingStream()` for arguments.
"""
function LZ4DecompressorStream(stream::IO; kwargs...)
    return TranscodingStream(LZ4Decompressor(), stream; kwargs...)
end

"""
Initializes the LZ4F Decompression Codec.
"""
function TranscodingStreams.initialize(codec::LZ4Decompressor)::Void
    LZ4F_createDecompressionContext(codec.dctx, LZ4F_getVersion())
    nothing
end

"""
Finalizes the LZ4F Decompression Codec.
"""
function TranscodingStreams.finalize(codec::LZ4Decompressor)::Void
    LZ4F_freeDecompressionContext(codec.dctx[])
    nothing
end

"""
Deompresses the data from `input` and writes to `output`.
If the input data is not properly formatted this function will throw an error.
"""
function TranscodingStreams.process(codec::LZ4Decompressor, input::Memory, output::Memory, error::Error)::Tuple{Int,Int,Symbol}
    data_read = 0
    data_written = 0

    try
        if input.size == 0
            (data_read, data_written, :end)
        else
            src_size = Ref{Csize_t}(input.size)
            dst_size = Ref{Csize_t}(output.size)
            LZ4F_decompress(codec.dctx[], output.ptr, dst_size, input.ptr, src_size, C_NULL)
            (src_size[], dst_size[], :ok)
        end

    catch err
        error[] = err
        (data_read, data_written, :error)
    end

end

