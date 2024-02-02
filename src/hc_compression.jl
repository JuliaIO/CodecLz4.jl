mutable struct SimpleRingBuffer
    buffer::Vector{UInt8}
    offset::Int
end

SimpleRingBuffer(buf_size::Integer) = SimpleRingBuffer(Vector{UInt8}(undef, buf_size), 0)
Base.pointer(buf::SimpleRingBuffer) = pointer(buf.buffer) + buf.offset
reset!(buf::SimpleRingBuffer) = buf.offset = 0

function copy_data!(dest::SimpleRingBuffer, src::Memory, data_size::Integer)
    checkbounds(src, data_size)
    if length(dest.buffer) < data_size
        throw(ArgumentError(
            "Cannot store $data_size bytes in buffer of size $(length(dest.buffer))"
        ))
    end

    if dest.offset + data_size > length(dest.buffer)
        dest.offset = 0
    end
    data_start = pointer(dest)
    unsafe_copyto!(data_start, src.ptr, data_size)

    dest.offset += data_size
    return data_start
end

mutable struct LZ4HCCompressor <: TranscodingStreams.Codec
    streamptr::Ptr{LZ4_streamHC_t}
    compressionlevel::Cint
    block_size::Int
    buffer::SimpleRingBuffer
end

"""
    LZ4HCCompressor(; kwargs...)

Creates an LZ4 HC compression codec.

# Keywords
- `compressionlevel::Integer=$LZ4HC_CLEVEL_DEFAULT`: compression level
- `block_size::Integer=1024`: The size in bytes to encrypt into each block. (Max 4MB)
"""
function LZ4HCCompressor(;
    compressionlevel::Integer=LZ4HC_CLEVEL_DEFAULT,
    block_size::Integer=1024
)
    if block_size > LZ4_MAX_INPUT_SIZE
        throw(ArgumentError("`block_size` larger than $LZ4_MAX_INPUT_SIZE."))
    end

    return LZ4HCCompressor(
        C_NULL,
        compressionlevel,
        block_size,
        SimpleRingBuffer(4 * block_size),
    )
end

const LZ4HCCompressorStream{S} = TranscodingStream{LZ4HCCompressor,S} where S<:IO

"""
    LZ4HCCompressorStream(stream::IO; kwargs...)

Creates an LZ4 HC compression stream.
See `LZ4HCCompressorStream()` and `TranscodingStream()` for arguments.
"""
function LZ4HCCompressorStream(stream::IO; kwargs...)
    x, y = splitkwargs(kwargs, (:compressionlevel, :block_size))
    return TranscodingStream(LZ4HCCompressor(; x...), stream; y...)
end

"""
   TranscodingStreams.initialize(codec::LZ4HCCompressor)

Initializes the LZ4 HC compression Codec.
"""
function TranscodingStreams.initialize(codec::LZ4HCCompressor)::Nothing
    codec.streamptr = LZ4_createStreamHC()
    nothing
end

"""
    TranscodingStreams.expectedsize(codec::Union{LZ4FastCompressor, LZ4HCCompressor}, input::Memory)

Returns the expected size of the transcoded data.
"""
function TranscodingStreams.expectedsize(codec::LZ4HCCompressor, input::Memory)::Int
    max_compressed_size(length(input), codec.block_size)
end

"""
   TranscodingStreams.minoutsize(codec::Union{LZ4FastCompressor, LZ4HCCompressor}, input::Memory)

Returns the minimum output size of `process`.
"""
function TranscodingStreams.minoutsize(codec::LZ4HCCompressor, input::Memory)::Int
    LZ4_compressBound(length(input)) + CINT_SIZE
end

"""
    TranscodingStreams.finalize(codec::LZ4HCCompressor)

Finalizes the LZHC Compression Codec.
"""
function TranscodingStreams.finalize(codec::LZ4HCCompressor)::Nothing
    LZ4_freeStreamHC(codec.streamptr)
    codec.streamptr = C_NULL
    nothing
end

"""
    TranscodingStreams.startproc(codec::LZ4HCCompressor, mode::Symbol, error::Error)

Starts processing with the codec
"""
function TranscodingStreams.startproc(
    codec::LZ4HCCompressor,
    mode::Symbol,
    error::Error
)::Symbol

    try
        LZ4_resetStreamHC(codec.streamptr, codec.compressionlevel)
        reset!(codec.buffer)
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
function TranscodingStreams.process(
    codec::LZ4HCCompressor,
    input::Memory,
    output::Memory,
    error::Error
)::Tuple{Int,Int,Symbol}

    length(input) == 0 && return (0, 0, :end)
    try
        data_size = min(length(input), codec.block_size)

        in_buffer = copy_data!(codec.buffer, input, data_size)
        out_buffer = Vector{UInt8}(undef, LZ4_compressBound(data_size))

        compressed_size = LZ4_compress_HC_continue(
            codec.streamptr,
            in_buffer,
            pointer(out_buffer),
            data_size,
            length(out_buffer)
        )

        checkbounds(output, compressed_size + CINT_SIZE)
        writeint(output, compressed_size)
        unsafe_copyto!(output.ptr+CINT_SIZE, pointer(out_buffer), compressed_size)

        return (data_size, compressed_size + CINT_SIZE, :ok)

    catch err
        error[] = err
        return (0, 0, :error)
    end
end
