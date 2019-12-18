"""
    lz4_compress(input::Union{Vector{UInt8},Base.CodeUnits{UInt8}}, acceleration::Integer=0)

Compresses `input` using LZ4_compress_fast. Returns a Vector{UInt8} of the compressed data.
"""
function lz4_compress(
    input::Union{Vector{UInt8},Base.CodeUnits{UInt8}},
    acceleration::Integer=0
)
    bound = LZ4_compressBound(length(input))
    bound == 0 && throw(LZ4Exception(
        "lz4_compress",
        "Input size $(length(input)) greater than LZ4_MAX_INPUT_VALUE. Cannot encode as a single block."
    ))

    out_buffer = Vector{UInt8}(undef, bound)
    out_size = LZ4_compress_fast(pointer(input), pointer(out_buffer), length(input), bound, acceleration)
    resize!(out_buffer, out_size)
end

"""
    lz4_hc_compress(input::Union{Vector{UInt8},Base.CodeUnits{UInt8}}, acceleration::Integer=$LZ4HC_CLEVEL_DEFAULT)

Compresses `input` using LZ4_compress_HC. Returns a Vector{UInt8} of the compressed data.
"""
function lz4_hc_compress(
    input::Union{Vector{UInt8},Base.CodeUnits{UInt8}},
    compressionlevel::Integer=LZ4HC_CLEVEL_DEFAULT
)
    bound = LZ4_compressBound(length(input))
    bound == 0 && throw(LZ4Exception(
        "lz4_hc_compress",
        "Input size $(length(input)) greater than LZ4_MAX_INPUT_VALUE. Cannot encode as a single block."
    ))

    out_buffer = Vector{UInt8}(undef, bound)
    out_size = LZ4_compress_HC(pointer(input), pointer(out_buffer), length(input), bound, compressionlevel)
    resize!(out_buffer, out_size)
end

"""
    lz4_decompress(input::Union{Vector{UInt8},Base.CodeUnits{UInt8}}, expected_size::Integer=input.size * 2)

Decompresses `input` using LZ4_decompress_safe.
`expected_size` must be equal to or larger than the expected decompressed size of the input or decompression will fail.
Returns a Vector{UInt8} of the decompressed data.
"""
function lz4_decompress(
    input::Union{Vector{UInt8},Base.CodeUnits{UInt8}},
    expected_size::Integer=length(input) * 2
)
    out_buffer = Vector{UInt8}(undef, expected_size)
    out_size = LZ4_decompress_safe(pointer(input), pointer(out_buffer), length(input), expected_size)
    resize!(out_buffer, out_size)
end
