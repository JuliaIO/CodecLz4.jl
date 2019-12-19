const BLOCK_SIZE = 1024  # TODO: Make variable
const CINT_SIZE = sizeof(Cint)

function writeint(mem::Memory, int::Cint)
    buf = reinterpret(UInt8, [int])

    checkbounds(mem, CINT_SIZE)
    unsafe_copyto!(mem.ptr, pointer(buf), CINT_SIZE)
    return CINT_SIZE
end

function readint(mem::Memory)
    buf = Vector{UInt8}(undef, CINT_SIZE)

    checkbounds(mem, CINT_SIZE)
    unsafe_copyto!(pointer(buf), mem.ptr, CINT_SIZE)
    return reinterpret(Cint, buf)[1]
end

mutable struct LZ4FastCompressor <: TranscodingStreams.Codec
    streamptr::Ptr{LZ4_stream_t}
    acceleration::Cint

    # Double buffering
    buffer::Array{UInt8,2}
    curr_buffer::Bool
end

"""
    LZ4FastCompressor(; kwargs...)

Creates an LZ4 compression codec.

# Keywords
- `acceleration::Integer=0`: acceleration factor
"""
function LZ4FastCompressor(; acceleration::Integer=0)
    return LZ4FastCompressor(
        Ptr{LZ4_stream_t}(C_NULL),
        acceleration,
        Array{UInt8}(undef, 2, LZ4_compressBound(BLOCK_SIZE)),
        false,
    )
end

const LZ4FastCompressorStream{S} = TranscodingStream{LZ4FastCompressor,S} where S<:IO

"""
    LZ4FastCompressor(stream::IO; kwargs...)

Creates an LZ4 compression stream. See `LZ4FastCompressor()` and `TranscodingStream()` for arguments.
"""
function LZ4FastCompressorStream(stream::IO; kwargs...)
    x, y = splitkwargs(kwargs, (:acceleration,))
    return TranscodingStream(LZ4FastCompressor(; x...), stream; y...)
end

"""
    TranscodingStreams.expectedsize(codec::LZ4FastCompressor, input::Memory)

Returns the expected size of the transcoded data.
"""
function TranscodingStreams.expectedsize(codec::LZ4FastCompressor, input::Memory)::Int
    bound = LZ4_compressBound(input.size)
    if bound == 0
        return ceil(Int, (LZ4_compressBound(BLOCK_SIZE) + CINT_SIZE) * input.size / BLOCK_SIZE)
    end
    bound
end

"""
   TranscodingStreams.minoutsize(codec::LZ4FastCompressor, input::Memory)

Returns the minimum output size of `process`.
"""
function TranscodingStreams.minoutsize(codec::LZ4FastCompressor, input::Memory)::Int
    LZ4_compressBound(input.size)
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
    codec.streamptr = Ptr{LZ4_stream_t}(C_NULL)
    nothing
end

"""
    TranscodingStreams.startproc(codec::LZ4FastCompressor, mode::Symbol, error::Error)

Starts processing with the codec
"""
function TranscodingStreams.startproc(codec::LZ4FastCompressor, mode::Symbol, error::Error)::Symbol
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
function TranscodingStreams.process(codec::LZ4FastCompressor, input::Memory, output::Memory, error::Error)::Tuple{Int,Int,Symbol}
    data_read = 0
    data_written = 0
    try
        if input.size == 0
            (data_read, data_written, :end)
        else
            in_buffer = pointer(codec.buffer[codec.curr_buffer + 1, :])

            data_size = min(input.size, BLOCK_SIZE)
            out_buffer = Vector{UInt8}(undef, LZ4_compressBound(data_size))
            unsafe_copyto!(in_buffer, input.ptr, data_size)

            data_written = LZ4_compress_fast_continue(codec.streamptr, in_buffer, pointer(out_buffer), data_size, output.size, codec.acceleration)

            # Update double buffer index
            codec.curr_buffer = !codec.curr_buffer

            writeint(output, data_written)
            unsafe_copyto!(output.ptr + CINT_SIZE, pointer(out_buffer), data_written)

            (data_size, data_written + CINT_SIZE, :ok)
        end

    catch err
        error[] = err
        (data_read, data_written, :error)
    end
end

mutable struct LZ4SafeDecompressor <: TranscodingStreams.Codec
    streamptr::Ptr{LZ4_streamDecode_t}

    # Double buffering
    buffer::Array{UInt8,2}
    curr_buffer::Bool
end

"""
    LZ4SafeDecompressor(; kwargs...)

Creates an LZ4 compression codec.
"""
function LZ4SafeDecompressor()
    return LZ4SafeDecompressor(
        Ptr{LZ4_streamDecode_t}(C_NULL),
        Array{UInt8}(undef, 2, BLOCK_SIZE),
        false,
    )
end

const LZ4SafeDecompressorStream{S} = TranscodingStream{LZ4SafeDecompressor,S} where S<:IO

"""
    LZ4SafeDecompressorStream(stream::IO; kwargs...)

Creates an LZ4 compression stream. See `LZ4SafeDecompressor()` and `TranscodingStream()` for arguments.
"""
function LZ4SafeDecompressorStream(stream::IO; kwargs...)
    return TranscodingStream(LZ4SafeDecompressor(), stream; kwargs...)
end

"""
    TranscodingStreams.expectedsize(codec::LZ4SafeDecompressor, input::Memory)

Returns the expected size of the transcoded data.
"""
function TranscodingStreams.expectedsize(codec::LZ4SafeDecompressor, input::Memory)::Int
    max(input.size * 2, BLOCK_SIZE) # TODO: better estimate?
end

"""
   TranscodingStreams.minoutsize(codec::LZ4SafeDecompressor, input::Memory)

Returns the minimum output size of `process`.
"""
function TranscodingStreams.minoutsize(codec::LZ4SafeDecompressor, input::Memory)::Int
    max(input.size * 2, BLOCK_SIZE)
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

Finalizes the LZ4F Compression Codec.
"""
function TranscodingStreams.finalize(codec::LZ4SafeDecompressor)::Nothing
    LZ4_freeStreamDecode(codec.streamptr)
    codec.streamptr = Ptr{LZ4_streamDecode_t}(C_NULL)
    nothing
end

"""
    TranscodingStreams.startproc(codec::LZ4SafeDecompressor, mode::Symbol, error::Error)

Starts processing with the codec
"""
function TranscodingStreams.startproc(codec::LZ4SafeDecompressor, mode::Symbol, error::Error)::Symbol
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
function TranscodingStreams.process(codec::LZ4SafeDecompressor, input::Memory, output::Memory, error::Error)::Tuple{Int,Int,Symbol}
    data_read = 0
    data_written = 0
    try
        if input.size == 0
            (data_read, data_written, :end)
        else
            if input.size < CINT_SIZE
                throw(LZ4Exception("LZ4SafeDecompressor", "Improperly formatted input"))
            end
            data_size = readint(input)

            # Get buffer from double buffer
            out_buffer = codec.buffer[codec.curr_buffer+1, :]
            codec.curr_buffer = !codec.curr_buffer

            data_written = LZ4_decompress_safe_continue(codec.streamptr, input.ptr+CINT_SIZE, pointer(out_buffer), data_size, output.size)

            # Update double buffer index
            codec.curr_buffer = !codec.curr_buffer

            unsafe_copyto!(output.ptr, pointer(out_buffer), data_written)

            codec.curr_buffer = !codec.curr_buffer

            (data_size + CINT_SIZE, data_written, :ok)
        end

    catch err
        error[] = err
        (data_read, data_written, :error)
    end
end


