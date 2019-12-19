mutable struct LZ4HCCompressor <: TranscodingStreams.Codec
    streamptr::Ptr{LZ4_streamHC_t}
    compressionlevel::Cint

    # Ring buffering
    buffer::Vector{UInt8}
    offset::Integer
end

"""
    LZ4HCCompressor(; kwargs...)

Creates an LZ4 compression codec.

# Keywords
- `compressionlevel::Integer=$LZ4HC_CLEVEL_DEFAULT`: compression level
"""
function LZ4HCCompressor(; compressionlevel::Integer=LZ4HC_CLEVEL_DEFAULT)
    return LZ4HCCompressor(
        Ptr{LZ4_streamHC_t}(C_NULL),
        compressionlevel,
        Vector{UInt8}(undef, 8 * LZ4_compressBound(BLOCK_SIZE)),
        0,
    )
end

const LZ4HCCompressorStream{S} = TranscodingStream{LZ4HCCompressor,S} where S<:IO

"""
    LZ4HCCompressorStream(stream::IO; kwargs...)

Creates an LZ4 compression stream. See `LZ4HCCompressorStream()` and `TranscodingStream()` for arguments.
"""
function LZ4HCCompressorStream(stream::IO; kwargs...)
    x, y = splitkwargs(kwargs, (:compressionlevel,))
    return TranscodingStream(LZ4HCCompressor(; x...), stream; y...)
end

"""
    TranscodingStreams.expectedsize(codec::LZ4HCCompressor, input::Memory)

Returns the expected size of the transcoded data.
"""
function TranscodingStreams.expectedsize(codec::LZ4HCCompressor, input::Memory)::Int
    ceil(Int, (LZ4_compressBound(BLOCK_SIZE) + CINT_SIZE) * input.size / BLOCK_SIZE)
end

"""
   TranscodingStreams.minoutsize(codec::LZ4HCCompressor, input::Memory)

Returns the minimum output size of `process`.
"""
function TranscodingStreams.minoutsize(codec::LZ4HCCompressor, input::Memory)::Int
    LZ4_compressBound(input.size)
end

"""
   TranscodingStreams.initialize(codec::LZ4HCCompressor)

Initializes the LZ4 Compression Codec.
"""
function TranscodingStreams.initialize(codec::LZ4HCCompressor)::Nothing
    codec.streamptr = LZ4_createStreamHC()
    nothing
end

"""
    TranscodingStreams.finalize(codec::LZ4HCCompressor)

Finalizes the LZ4F Compression Codec.
"""
function TranscodingStreams.finalize(codec::LZ4HCCompressor)::Nothing
    LZ4_freeStreamHC(codec.streamptr)
    codec.streamptr = Ptr{LZ4_streamHC_t}(C_NULL)
    nothing
end

"""
    TranscodingStreams.startproc(codec::LZ4HCCompressor, mode::Symbol, error::Error)

Starts processing with the codec
"""
function TranscodingStreams.startproc(codec::LZ4HCCompressor, mode::Symbol, error::Error)::Symbol
    try
        LZ4_resetStreamHC(codec.streamptr, codec.compressionlevel)
        :ok
    catch err
        error[] = err
        :error
    end
end

"""
    TranscodingStreams.process(codec::LZ4HCCompressor, input::Memory, output::Memory, error::Error)

Compresses the data from `input` and writes to `output`.
The process follows the compression example from
https://github.com/lz4/lz4/blob/dev/examples/HCStreaming_ringBuffer.c
wherein each block of encoded data is prefixed by the number of bytes contained in that block.
Decoding can be done through the LZ4SafeDecompressor.
"""
function TranscodingStreams.process(codec::LZ4HCCompressor, input::Memory, output::Memory, error::Error)::Tuple{Int,Int,Symbol}
    try
        if input.size == 0
            (0, 0, :end)
        else
            data_size = min(input.size, BLOCK_SIZE)

            buffer_ptr = pointer(codec.buffer) + codec.offset
            out_buffer = Vector{UInt8}(undef, LZ4_compressBound(data_size))
            unsafe_copyto!(buffer_ptr, input.ptr, data_size)

            data_written = LZ4_compress_HC_continue(codec.streamptr, buffer_ptr, pointer(out_buffer), data_size, output.size)
            writeint(output, data_written)
            unsafe_copyto!(output.ptr+CINT_SIZE, pointer(out_buffer), data_written)

            codec.offset += data_size
            if codec.offset + BLOCK_SIZE >= length(codec.buffer)
                codec.offset = 0
            end

            (data_size, data_written + CINT_SIZE, :ok)
        end

    catch err
        error[] = err
        (0, 0, :error)
    end
end
