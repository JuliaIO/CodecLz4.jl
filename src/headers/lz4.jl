# Julia wrapper for header: /usr/local/include/lz4.h
# docstrings copied from /usr/local/include/lz4.h

function check_compression_error(ret::Integer, function_name::AbstractString)
    ret == 0 && throw(LZ4Exception(function_name, "Compression failed."))
    return ret
end

function check_decompression_error(ret::Integer, function_name::AbstractString)
    ret < 0 && throw(LZ4Exception(function_name, "Decompression failed."))
    return ret
end

function check_initialized(stream::Ptr{LZ4_stream_t})
    if stream == Ptr{LZ4_stream_t}(C_NULL)
        throw(LZ4Exception("LZ4_stream_t", "Uninitialized compression stream"))
    end
end

function check_initialized(stream::Ptr{LZ4_streamDecode_t})
    if stream == Ptr{LZ4_streamDecode_t}(C_NULL)
        throw(LZ4Exception("LZ4_streamDecode_t", "Uninitialized decompression stream"))
    end
end

"""
    LZ4_compress_fast(src, dst, srcsize, dstcapacity=1)

Compresses `srcsize` bytes from buffer `src`
into already allocated `dst` buffer of size `dstcapacity`.
Compression is guaranteed to succeed if `dstcapacity` >= LZ4_compressBound(srcsize).
It also runs faster, so it's a recommended setting.
If the function cannot compress `src` into a limited `dst` budget,
compression stops *immediately*, and the function result is zero.
As a consequence, `dst` content is not valid.

Also allows to select an `acceleration` factor.
The larger the acceleration value, the faster the algorithm, but also the lesser the compression.
It's a trade-off. It can be fine tuned, with each successive value providing roughly +~3% to speed.
Values <= 0 will be replaced by the default which is 1.

This function never writes outside `dst` buffer, nor read outside `source` buffer.
    srcsize : supported max value is LZ4_MAX_INPUT_VALUE
    dstcapacity : full or partial size of buffer `dst` (which must be already allocated)

Returns the number of bytes written into buffer `dst` (necessarily <= dstcapacity)
"""
function LZ4_compress_fast(src, dst, srcsize, dstcapacity, acceleration=1)
    ret = @gcsafe_ccall liblz4.LZ4_compress_fast(src::Ptr{UInt8}, dst::Ptr{UInt8}, srcsize::Cint, dstcapacity::Cint, acceleration::Cint)::Cint
    check_compression_error(ret, "LZ4_compress_fast")
end

"""
    LZ4_compress_destSize(src, dst, srcsize, dstcapacity)

Reverse the logic : compresses as much data as possible from `src` buffer
into already allocated buffer `dst` of size `dstcapacity`.
This function either compresses the entire `src` content into `dst` if it's large enough,
or fill `dst` buffer completely with as much data as possible from `src`.
    *srcsize : will be modified to indicate how many bytes where read from `src` to fill `dst`.
                  New value is necessarily <= old value.

Returns number of bytes written into `dst` (necessarily <= dstcapacity)
"""
function LZ4_compress_destSize(src, dst, srcsize, dstcapacity)
    ret = @gcsafe_ccall liblz4.LZ4_compress_destSize(src::Ptr{UInt8}, dst::Ptr{UInt8}, srcsize::Ptr{Cint}, dstcapacity::Cint)::Cint
    check_compression_error(ret, "LZ4_compress_destSize")
end

"""
    LZ4_compressBound(inputsize)

Provides the maximum size that LZ4 compression may output in a "worst case" scenario (input data not compressible)
This function is primarily useful for memory allocation purposes (destination buffer size).
Macro LZ4_COMPRESSBOUND() is also provided for compilation-time evaluation (stack memory allocation for example).
Note that LZ4_compress_default() compress faster when dest buffer size is >= LZ4_compressBound(srcsize)
    inputsize  : max supported value is LZ4_MAX_INPUT_SIZE

Returns maximum output size in a "worst case" scenario or 0, if input size is too large ( > LZ4_MAX_INPUT_SIZE)
"""
function LZ4_compressBound(inputsize)
    ccall((:LZ4_compressBound, liblz4), Cint, (Cint,), inputsize)
end

"""
    LZ4_createStream()

Will allocate and initialize an `LZ4_stream_t` structure.
"""
function LZ4_createStream()
    str = ccall((:LZ4_createStream, liblz4), Ptr{LZ4_stream_t}, ())
    if str == C_NULL # Could not allocate memory
        throw(OutOfMemoryError())
    end
    return str
end

"""
    LZ4_freeStream(streamptr::Ptr{LZ4_stream_t})

Releases memory allocated by LZ4_createStream.
"""
function LZ4_freeStream(streamptr::Ptr{LZ4_stream_t})
    ccall((:LZ4_freeStream, liblz4), Cint, (Ptr{LZ4_stream_t},), streamptr)
end

"""
    LZ4_resetStream(streamptr)

An LZ4_stream_t structure can be allocated once and re-used multiple times.
Use this function to start compressing a new stream.
"""
function LZ4_resetStream(streamptr::Ptr{LZ4_stream_t})
    check_initialized(streamptr)
    ccall((:LZ4_resetStream, liblz4), Cvoid, (Ptr{LZ4_stream_t},), streamptr)
end

"""
    LZ4_compress_fast_continue(streamptr, src, dst, srcsize, dstcapacity, acceleration)

Compress content into `src` using data from previously compressed blocks, improving compression ratio.
`dst` buffer must be already allocated.
If dstcapacity >= LZ4_compressBound(srcsize), compression is guaranteed to succeed, and runs faster.

Important : Up to 64KB of previously compressed data is assumed to remain present and unmodified in memory !
Special 1 : If input buffer is a double-buffer, it can have any size, including < 64 KB.
Special 2 : If input buffer is a ring-buffer, it can have any size, including < 64 KB.

Returns size of compressed block.
After an error, the stream status is invalid, it can only be reset or freed.
"""
function LZ4_compress_fast_continue(streamptr::Ptr{LZ4_stream_t}, src, dst, srcsize, dstcapacity, acceleration=1)
    check_initialized(streamptr)
    ret = ccall((:LZ4_compress_fast_continue, liblz4), Cint, (Ptr{LZ4_stream_t}, Ptr{UInt8}, Ptr{UInt8}, Cint, Cint, Cint), streamptr, src, dst, srcsize, dstcapacity, acceleration)
    check_compression_error(ret, "LZ4_compress_fast_continue")
end

"""
    LZ4_decompress_safe(src, dst, cmpsize, dstcapacity)

Decompresses `cmpsize` bytes from buffer `src` into `dst`.
If destination buffer is not large enough, decoding will stop and output an error.
If the source stream is detected malformed, the function will stop decoding and error.
This function is protected against buffer overflow exploits, including malicious data packets.
It never writes outside output buffer, nor reads outside input buffer.

cmpsize : is the exact complete size of the compressed block.
dstcapacity : is the size of destination buffer, which must be already allocated.

Returns the number of bytes decompressed into destination buffer (necessarily <= dstcapacity)
"""
function LZ4_decompress_safe(src, dst, cmpsize, dstcapacity)
    ret = @gcsafe_ccall liblz4.LZ4_decompress_safe(src::Ptr{UInt8}, dst::Ptr{UInt8}, cmpsize::Cint, dstcapacity::Cint)::Cint
    check_decompression_error(ret, "LZ4_decompress_safe")
end

"""
    LZ4_createStreamDecode()

These decoding functions work the same as
creation / destruction of streaming decompression tracking structure.
A tracking structure can be re-used multiple times sequentially.
"""
function LZ4_createStreamDecode()
    str = ccall((:LZ4_createStreamDecode, liblz4), Ptr{LZ4_streamDecode_t}, ())
    if str == C_NULL # Could not allocate memory
        throw(OutOfMemoryError())
    end
    return str
end

"""
    LZ4_freeStreamDecode(streamptr)

These decoding functions work the same as
creation / destruction of streaming decompression tracking structure.
A tracking structure can be re-used multiple times sequentially.
"""
function LZ4_freeStreamDecode(streamptr::Ptr{LZ4_streamDecode_t})
    ccall((:LZ4_freeStreamDecode, liblz4), Cint, (Ptr{LZ4_streamDecode_t},), streamptr)
end

"""
    LZ4_setStreamDecode(streamptr, dictionary, dictsize)

An LZ4_streamDecode_t structure can be allocated once and re-used multiple times.
Use this function to start decompression of a new stream of blocks.
A dictionary can optionally be set. Use NULL or size 0 for a simple reset order.
Returns 1 if OK
"""
function LZ4_setStreamDecode(streamptr::Ptr{LZ4_streamDecode_t}, dictionary=C_NULL, dictsize=0)
    check_initialized(streamptr)
    ret = ccall((:LZ4_setStreamDecode, liblz4), Cint, (Ptr{LZ4_streamDecode_t}, Ptr{UInt8}, Cint), streamptr, dictionary, dictsize)
    ret == 0 && throw(LZ4Exception("LZ4_setStreamDecode", "Stream reinitialization failed."))
    return ret
end

"""
    LZ4_decompress_safe_continue(streamptr, src, dst, srcsize, dstcapacity)

These decoding functions allow decompression of consecutive blocks in "streaming" mode.
A block is an unsplittable entity, it must be presented entirely to a decompression function.
Decompression functions only accept one block at a time.
Previously decoded blocks *must* remain available at the memory position where they were decoded (up to 64 KB).

Special : if application sets a ring buffer for decompression, it must respect one of the following conditions :
- Exactly same size as encoding buffer, with same update rule (block boundaries at same positions)
  In which case, the decoding & encoding ring buffer can have any size, including very small ones ( < 64 KB).
- Larger than encoding buffer, by a minimum of maxBlockSize more bytes.
  maxBlockSize is implementation dependent. It's the maximum size of any single block.
  In which case, encoding and decoding buffers do not need to be synchronized,
  and encoding ring buffer can have any size, including small ones ( < 64 KB).
- _At least_ 64 KB + 8 bytes + maxBlockSize.
  In which case, encoding and decoding buffers do not need to be synchronized,
  and encoding ring buffer can have any size, including larger than decoding buffer.
Whenever these conditions are not possible, save the last 64KB of decoded data into a safe buffer,
and indicate where it is saved using `LZ4_setStreamDecode()` before decompressing next block.
"""
function LZ4_decompress_safe_continue(streamptr::Ptr{LZ4_streamDecode_t}, src, dst, srcsize, dstcapacity)
    check_initialized(streamptr)
    ret = ccall((:LZ4_decompress_safe_continue, liblz4), Cint, (Ptr{LZ4_streamDecode_t}, Ptr{UInt8}, Ptr{UInt8}, Cint, Cint), streamptr, src, dst, srcsize, dstcapacity)
    check_decompression_error(ret, "LZ4_decompress_safe_continue")
end
