const CINT_SIZE = sizeof(Cint)

function writeint(mem::Memory, int::Cint)
    checkbounds(mem, sizeof(Cint))
    unsafe_store!(Ptr{Cint}(mem.ptr), int)
    return CINT_SIZE
end

function readint(mem::Memory)
    checkbounds(mem, sizeof(Cint))
    return unsafe_load(Ptr{Cint}(mem.ptr))
end

mutable struct SimpleDoubleBuffer
    buffer::Array{UInt8, 2}
    next::Bool
end

SimpleDoubleBuffer(buf_size::Integer) = SimpleDoubleBuffer(Array{UInt8}(undef, buf_size, 2), false)
function get_buffer!(db::SimpleDoubleBuffer)
    out_buffer = @view(db.buffer[:, db.next+1])
    db.next = !db.next  # Update index
    return out_buffer
end

function max_compressed_size(in_size::Integer, block_size::Integer)
    num_blocks = ceil(Int, in_size / block_size)
    compressed_size = LZ4_compressBound(block_size) + CINT_SIZE

    return compressed_size * num_blocks
end

mutable struct LZ4FastCompressor <: TranscodingStreams.Codec
    streamptr::Ptr{LZ4_stream_t}
    acceleration::Cint
    block_size::Int
    buffer::SimpleDoubleBuffer
end

"""
    LZ4FastCompressor(; kwargs...)

Creates an LZ4 compression codec.

# Keywords
- `acceleration::Integer=0`: acceleration factor
- `block_size::Integer=1024`: The size in bytes to encrypt into each block.
"""
function LZ4FastCompressor(; acceleration::Integer=0, block_size::Integer=1024)
    if block_size > LZ4_MAX_INPUT_SIZE
        throw(ArgumentError("`block_size` larger than $LZ4_MAX_INPUT_SIZE."))
    end

    return LZ4FastCompressor(C_NULL, acceleration, block_size, SimpleDoubleBuffer(block_size))
end

const LZ4FastCompressorStream{S} = TranscodingStream{LZ4FastCompressor,S} where S<:IO

"""
    LZ4FastCompressor(stream::IO; kwargs...)

Creates an LZ4 compression stream. See `LZ4FastCompressor()` and `TranscodingStream()` for arguments.
"""
function LZ4FastCompressorStream(stream::IO; kwargs...)
    x, y = splitkwargs(kwargs, (:acceleration, :block_size))
    return TranscodingStream(LZ4FastCompressor(; x...), stream; y...)
end

"""
    TranscodingStreams.expectedsize(codec::Union{LZ4FastCompressor, LZ4HCCompressor}, input::Memory)

Returns the expected size of the transcoded data.
"""
function TranscodingStreams.expectedsize(codec::LZ4FastCompressor, input::Memory)::Int
    max_compressed_size(length(input), codec.block_size)
end

"""
   TranscodingStreams.minoutsize(codec::Union{LZ4FastCompressor, LZ4HCCompressor}, input::Memory)

Returns the minimum output size of `process`.
"""
function TranscodingStreams.minoutsize(codec::LZ4FastCompressor, input::Memory)::Int
    LZ4_compressBound(length(input)) + CINT_SIZE
end

"""
   TranscodingStreams.initialize(codec::LZ4FastCompressor)

Initializes the LZ4 Compression Codec.
"""
function TranscodingStreams.initialize(codec::LZ4FastCompressor)::Nothing
    codec.streamptr = LZ4_createStream()
    nothing
end

"""
    TranscodingStreams.finalize(codec::LZ4FastCompressor)

Finalizes the LZ4 Compression Codec.
"""
function TranscodingStreams.finalize(codec::LZ4FastCompressor)::Nothing
    LZ4_freeStream(codec.streamptr)
    codec.streamptr = C_NULL
    nothing
end

"""
    TranscodingStreams.startproc(codec::LZ4FastCompressor, mode::Symbol, error::Error)

Starts processing with the codec
"""
function TranscodingStreams.startproc(
    codec::LZ4FastCompressor,
    mode::Symbol,
    error::Error
)::Symbol

    try
        LZ4_resetStream(codec.streamptr)
        :ok
    catch err
        error[] = err
        :error
    end
end

"""
    TranscodingStreams.process(codec::LZ4FastCompressor, input::Memory, output::Memory, error::Error)

Compresses the data from `input` and writes to `output`.
The process follows the compression example from
https://github.com/lz4/lz4/blob/dev/examples/blockStreaming_doubleBuffer.c
wherein each block of encoded data is prefixed by the number of bytes contained in that block.
Decoding can be done through the LZ4SafeDecompressor.
"""
function TranscodingStreams.process(
    codec::LZ4FastCompressor,
    input::Memory,
    output::Memory,
    error::Error
)::Tuple{Int,Int,Symbol}

    length(input) == 0 && return (0, 0, :end)
    try
        in_buffer = get_buffer!(codec.buffer)

        data_size = min(length(input), codec.block_size)
        out_buffer = Vector{UInt8}(undef, LZ4_compressBound(data_size))
        GC.@preserve in_buffer unsafe_copyto!(pointer(in_buffer), input.ptr, data_size)

        compressed_size = LZ4_compress_fast_continue(
            codec.streamptr,
            in_buffer,
            out_buffer,
            data_size,
            length(out_buffer),
            codec.acceleration,
        )

        checkbounds(output, compressed_size + CINT_SIZE)
        writeint(output, compressed_size)
        GC.@preserve out_buffer unsafe_copyto!(output.ptr + CINT_SIZE, pointer(out_buffer), compressed_size)

        return (data_size, compressed_size + CINT_SIZE, :ok)
    catch err
        error[] = err
        return (0, 0, :error)
    end
end

mutable struct LZ4SafeDecompressor <: TranscodingStreams.Codec
    streamptr::Ptr{LZ4_streamDecode_t}
    block_size::Int
    buffer::SimpleDoubleBuffer
end

"""
    LZ4SafeDecompressor(; kwargs...)

Creates an LZ4 compression codec.

# Keywords
- `block_size::Integer=1024`: The size in bytes of unecrypted data contained in each block.
    Must match or exceed the compression `block_size` or decompression will fail.
"""
function LZ4SafeDecompressor(; block_size::Integer=1024)
    return LZ4SafeDecompressor(C_NULL, block_size, SimpleDoubleBuffer(block_size))
end

const LZ4SafeDecompressorStream{S} = TranscodingStream{LZ4SafeDecompressor,S} where S<:IO

"""
    LZ4SafeDecompressorStream(stream::IO; kwargs...)

Creates an LZ4 compression stream. See `LZ4SafeDecompressor()` and `TranscodingStream()` for arguments.
"""
function LZ4SafeDecompressorStream(stream::IO; kwargs...)
    x, y = splitkwargs(kwargs, (:block_size,))
    return TranscodingStream(LZ4SafeDecompressor(; x...), stream; y...)
end

"""
    TranscodingStreams.expectedsize(codec::LZ4SafeDecompressor, input::Memory)

Returns the expected size of the transcoded data.
"""
function TranscodingStreams.expectedsize(codec::LZ4SafeDecompressor, input::Memory)::Int
    max(length(input) * 2, codec.block_size)
end

"""
   TranscodingStreams.minoutsize(codec::LZ4SafeDecompressor, input::Memory)

Returns the minimum output size of `process`.
"""
function TranscodingStreams.minoutsize(codec::LZ4SafeDecompressor, input::Memory)::Int
    max(length(input) * 2, codec.block_size)
end

"""
   TranscodingStreams.initialize(codec::LZ4SafeDecompressor)

Initializes the LZ4 Compression Codec.
"""
function TranscodingStreams.initialize(codec::LZ4SafeDecompressor)::Nothing
    codec.streamptr = LZ4_createStreamDecode()
    nothing
end

"""
    TranscodingStreams.finalize(codec::LZ4SafeDecompressor)

Finalizes the LZ4SafeDecompression Codec.
"""
function TranscodingStreams.finalize(codec::LZ4SafeDecompressor)::Nothing
    LZ4_freeStreamDecode(codec.streamptr)
    codec.streamptr = C_NULL
    nothing
end

"""
    TranscodingStreams.startproc(codec::LZ4SafeDecompressor, mode::Symbol, error::Error)

Starts processing with the codec
"""
function TranscodingStreams.startproc(
    codec::LZ4SafeDecompressor,
    mode::Symbol,
    error::Error
)::Symbol

    try
        LZ4_setStreamDecode(codec.streamptr)
        :ok
    catch err
        error[] = err
        :error
    end
end

"""
    TranscodingStreams.process(codec::LZ4SafeDecompressor, input::Memory, output::Memory, error::Error)

Compresses the data from `input` and writes to `output`.
The process follows the decompression example from
https://github.com/lz4/lz4/blob/dev/examples/blockStreaming_doubleBuffer.c
and requires each block of encoded data to be prefixed by the number of bytes contained in that block.
"""
function TranscodingStreams.process(
    codec::LZ4SafeDecompressor,
    input::Memory,
    output::Memory,
    error::Error
)::Tuple{Int,Int,Symbol}

    length(input) == 0 && return (0, 0, :end)
    try
        out_buffer = get_buffer!(codec.buffer)
        data_size = readint(input)

        decompressed_size = LZ4_decompress_safe_continue(
            codec.streamptr,
            input.ptr+CINT_SIZE,
            out_buffer,
            data_size,
            length(out_buffer)
        )

        checkbounds(output, decompressed_size)
        GC.@preserve out_buffer unsafe_copyto!(output.ptr, pointer(out_buffer), decompressed_size)

        return (data_size + CINT_SIZE, decompressed_size, :ok)
    catch err
        error[] = err
        return (0, 0, :error)
    end
end
