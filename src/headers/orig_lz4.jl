# Julia wrapper for header: /usr/local/include/lz4.h
# This is for completeness and remains untested for now

"""
    LZ4_compress_default(src, dst, srcsize, dstCapacity)

Compresses 'srcSize' bytes from buffer 'src'
into already allocated 'dst' buffer of size 'dstCapacity'.
Compression is guaranteed to succeed if 'dstCapacity' >= LZ4_compressBound(srcSize).
It also runs faster, so it's a recommended setting.
If the function cannot compress 'src' into a limited 'dst' budget,
compression stops *immediately*, and the function result is zero.
As a consequence, 'dst' content is not valid.
This function never writes outside 'dst' buffer, nor read outside 'source' buffer.
    srcSize : supported max value is LZ4_MAX_INPUT_VALUE
    dstCapacity : full or partial size of buffer 'dst' (which must be already allocated)
    return  : the number of bytes written into buffer 'dst' (necessarily <= dstCapacity)
              or 0 if compression fails */
"""
function LZ4_compress_default(src, dst, srcsize, dstCapacity)
    ccall((:LZ4_compress_default, liblz4), Int32, (Ptr{UInt8}, Ptr{UInt8}, Int32, Int32), src, dst, srcsize, dstCapacity)
end

"""
    LZ4_decompress_safe(src, dst, cmpsize, maxdcmpsize)

compressedSize : is the exact complete size of the compressed block.
dstCapacity : is the size of destination buffer, which must be already allocated.
return : the number of bytes decompressed into destination buffer (necessarily <= dstCapacity)
         If destination buffer is not large enough, decoding will stop and output an error code (negative value).
         If the source stream is detected malformed, the function will stop decoding and return a negative result.
         This function is protected against buffer overflow exploits, including malicious data packets.
         It never writes outside output buffer, nor reads outside input buffer.
"""
function LZ4_decompress_safe(src, dst, cmpsize, maxdcmpsize)
    ccall((:LZ4_decompress_safe, liblz4), Int32, (Ptr{UInt8}, Ptr{UInt8}, Int32, Int32), src, dst, cmpsize, maxdcmpsize)
end

"""
    LZ4_compressBound(inputsize)

Provides the maximum size that LZ4 compression may output in a "worst case" scenario (input data not compressible)
This function is primarily useful for memory allocation purposes (destination buffer size).
Macro LZ4_COMPRESSBOUND() is also provided for compilation-time evaluation (stack memory allocation for example).
Note that LZ4_compress_default() compress faster when dest buffer size is >= LZ4_compressBound(srcSize)
    inputSize  : max supported value is LZ4_MAX_INPUT_SIZE
    return : maximum output size in a "worst case" scenario
          or 0, if input size is too large ( > LZ4_MAX_INPUT_SIZE)
"""
function LZ4_compressBound(inputsize)
    ccall((:LZ4_compressBound, liblz4), Int32, (Int32,), inputsize)
end

"""
    LZ4_compress_fast(src, dst, srcsize, dstCapacity, acceleration)

Same as LZ4_compress_default(), but allows to select an "acceleration" factor.
The larger the acceleration value, the faster the algorithm, but also the lesser the compression.
It's a trade-off. It can be fine tuned, with each successive value providing roughly +~3% to speed.
An acceleration value of "1" is the same as regular LZ4_compress_default()
Values <= 0 will be replaced by ACCELERATION_DEFAULT (see lz4.c), which is 1.
"""
function LZ4_compress_fast(src, dst, srcsize, dstCapacity, acceleration)
    ccall((:LZ4_compress_fast, liblz4), Int32, (Ptr{UInt8}, Ptr{UInt8}, Int32, Int32, Int32), src, dst, srcsize, dstCapacity, acceleration)
end

function LZ4_sizeofState()
    ccall((:LZ4_sizeofState, liblz4), Int32, ())
end

"""
    LZ4_compress_fast_extState()

Same compression function, just using an externally allocated memory space to store compression state.
Use LZ4_sizeofState() to know how much memory must be allocated,
and allocate it on 8-bytes boundaries (using malloc() typically).
Then, provide it as 'void* state' to compression function.
"""
function LZ4_compress_fast_extState(state, src, dst, srcsize, dstCapacity, acceleration)
    ccall((:LZ4_compress_fast_extState, liblz4), Int32, (Ptr{Cvoid}, Ptr{UInt8}, Ptr{UInt8}, Int32, Int32, Int32), state, src, dst, srcsize, dstCapacity, acceleration)
end

"""
    LZ4_compress_destSize(src, dst, srcsize, dstCapacity)

Reverse the logic : compresses as much data as possible from 'src' buffer
into already allocated buffer 'dst' of size 'targetDestSize'.
This function either compresses the entire 'src' content into 'dst' if it's large enough,
or fill 'dst' buffer completely with as much data as possible from 'src'.
    *srcSizePtr : will be modified to indicate how many bytes where read from 'src' to fill 'dst'.
                  New value is necessarily <= old value.
    return : Nb bytes written into 'dst' (necessarily <= targetDestSize)
             or 0 if compression fails
"""
function LZ4_compress_destSize(src, dst, srcsize, dstCapacity)
    ccall((:LZ4_compress_destSize, liblz4), Int32, (Ptr{UInt8}, Ptr{UInt8}, Ptr{Int32}, Int32), src, dst, srcsize, dstCapacity)
end

"""
    LZ4_decompress_fast(rc, dst, origsize)

originalSize : is the original uncompressed size
return : the number of bytes read from the source buffer (in other words, the compressed size)
         If the source stream is detected malformed, the function will stop decoding and return a negative result.
         Destination buffer must be already allocated. Its size must be >= 'originalSize' bytes.
note : This function respects memory boundaries for *properly formed* compressed data.
       It is a bit faster than LZ4_decompress_safe().
       However, it does not provide any protection against intentionally modified data stream (malicious input).
       Use this function in trusted environment only (data to decode comes from a trusted source).
"""
function LZ4_decompress_fast(src, dst, origsize)
    ccall((:LZ4_decompress_fast, liblz4), Int32, (Ptr{UInt8}, Ptr{UInt8}, Int32), src, dst, origsize)
end

"""
    LZ4_decompress_safe_partial(src, dst, cmpsize, tgtoutputsize, maxdcmpsize)

This function decompress a compressed block of size 'srcSize' at position 'src'
into destination buffer 'dst' of size 'dstCapacity'.
The function will decompress a minimum of 'targetOutputSize' bytes, and stop after that.
However, it's not accurate, and may write more than 'targetOutputSize' (but <= dstCapacity).
@return : the number of bytes decoded in the destination buffer (necessarily <= dstCapacity)
   Note : this number can be < 'targetOutputSize' should the compressed block contain less data.
         Always control how many bytes were decoded.
         If the source stream is detected malformed, the function will stop decoding and return a negative result.
         This function never writes outside of output buffer, and never reads outside of input buffer. It is therefore protected against malicious data packets.
"""
function LZ4_decompress_safe_partial(src, dst, cmpsize, tgtoutputsize, maxdcmpsize)
    ccall((:LZ4_decompress_safe_partial, liblz4), Int32, (Ptr{UInt8}, Ptr{UInt8}, Int32, Int32, Int32), src, dst, cmpsize, tgtoutputsize, maxdcmpsize)
end

"""
    LZ4_createStream()

Will allocate and initialize an `LZ4_stream_t` structure.
"""
function LZ4_createStream()
    ccall((:LZ4_createStream, liblz4), Ptr{LZ4_stream_t}, ())
end

"""
    LZ4_freeStream(streamptr::Ptr{LZ4_stream_t})

Releases memory allocated by LZ4_createStream.
"""
function LZ4_freeStream(streamptr::Ptr{LZ4_stream_t})
    ccall((:LZ4_freeStream, liblz4), Int32, (Ptr{LZ4_stream_t},), streamptr)
end

"""
    LZ4_resetStream(streamptr)

An LZ4_stream_t structure can be allocated once and re-used multiple times.
Use this function to start compressing a new stream.
"""
function LZ4_resetStream(streamptr)
    ccall((:LZ4_resetStream, liblz4), Cvoid, (Ptr{LZ4_stream_t},),streamptr)
end


"""
    LZ4_loadDict(streamptr, dictionary, dictSize)

Use this function to load a static dictionary into LZ4_stream_t.
Any previous data will be forgotten, only 'dictionary' will remain in memory.
Loading a size of 0 is allowed, and is the same as reset.
@return : dictionary size, in bytes (necessarily <= 64 KB)
"""
function LZ4_loadDict(streamptr, dictionary, dictSize)
    ccall((:LZ4_loadDict, liblz4), Int32, (Ptr{LZ4_stream_t}, Ptr{UInt8}, Int32), streamptr, dictionary, dictSize)
end

"""
    LZ4_compress_fast_continue(streamptr, src, dst, srcSize, dstCapacity, acceleration)

Compress content into 'src' using data from previously compressed blocks, improving compression ratio.
'dst' buffer must be already allocated.
If dstCapacity >= LZ4_compressBound(srcSize), compression is guaranteed to succeed, and runs faster.

Important : Up to 64KB of previously compressed data is assumed to remain present and unmodified in memory !
Special 1 : If input buffer is a double-buffer, it can have any size, including < 64 KB.
Special 2 : If input buffer is a ring-buffer, it can have any size, including < 64 KB.

@return : size of compressed block
          or 0 if there is an error (typically, compressed data cannot fit into 'dst')
After an error, the stream status is invalid, it can only be reset or freed.
"""
function LZ4_compress_fast_continue(streamptr, src, dst, srcSize, dstCapacity, acceleration)
    ccall((:LZ4_compress_fast_continue, liblz4), Int32, (Ptr{LZ4_stream_t}, Ptr{UInt8}, Ptr{UInt8}, Int32, Int32, Int32), streamptr, src, dst, srcSize, dstCapacity, acceleration)
end

"""
    LZ4_saveDict(streamptr, safeBuffer, dictSize)

If previously compressed data block is not guaranteed to remain available at its current memory location,
save it into a safer place (char* safeBuffer).
Note : it's not necessary to call LZ4_loadDict() after LZ4_saveDict(), dictionary is immediately usable.
@return : saved dictionary size in bytes (necessarily <= dictSize), or 0 if error.
"""
function LZ4_saveDict(streamptr, safeBuffer, dictSize)
    ccall((:LZ4_compress_fast_continue, liblz4), Int32, (Ptr{LZ4_stream_t}, Ptr{UInt8}, Int32), streamptr, safeBuffer, dictSize)
end

"""
    LZ4_createStreamDecode()

These decoding functions work the same as
creation / destruction of streaming decompression tracking structure.
A tracking structure can be re-used multiple times sequentially.
"""
function LZ4_createStreamDecode()
    ccall((:LZ4_createStreamDecode, liblz4), Ptr{LZ4_streamDecode_t}, ())
end

"""
    LZ4_freeStreamDecode(LZ4_stream)

These decoding functions work the same as
creation / destruction of streaming decompression tracking structure.
A tracking structure can be re-used multiple times sequentially.
"""
function LZ4_freeStreamDecode(LZ4_stream)
    ccall((:LZ4_freeStreamDecode, liblz4), Int32, (Ptr{LZ4_streamDecode_t},), LZ4_stream)
end

"""
    LZ4_setStreamDecode()

An LZ4_streamDecode_t structure can be allocated once and re-used multiple times.
Use this function to start decompression of a new stream of blocks.
A dictionary can optionnally be set. Use NULL or size 0 for a simple reset order.
@return : 1 if OK, 0 if error
"""
function LZ4_setStreamDecode(LZ4_streamDecode, dictionary, dictSize)
    ccall((:LZ4_setStreamDecode, liblz4), Int32, (Ptr{LZ4_streamDecode_t}, Ptr{UInt8}, Int32), LZ4_streamDecode, dictionary, dictSize)
end

"""
    LZ4_decompress_*_continue()

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
and indicate where it is saved using LZ4_setStreamDecode() before decompressing next block.
"""
function LZ4_decompress_safe_continue(LZ4_streamDecode, src, dst, srcSize, dstCapacity)
    ccall((:LZ4_decompress_safe_continue, liblz4), Int32, (Ptr{LZ4_streamDecode_t}, Ptr{UInt8}, Ptr{UInt8}, Int32, Int32), LZ4_streamDecode, src, dst, srcSize, dstCapacity)
end

"""
    LZ4_decompress_*_continue()

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
and indicate where it is saved using LZ4_setStreamDecode() before decompressing next block.
"""
function LZ4_decompress_fast_continue(LZ4_streamDecode, src, dst, originalSize)
    ccall((:LZ4_decompress_fast_continue, liblz4), Int32, (Ptr{LZ4_streamDecode_t}, Ptr{UInt8}, Ptr{UInt8}, Int32), LZ4_streamDecode, src, dst, originalSize)
end

"""
    LZ4_decompress_*_usingDict()

These decoding functions work the same as
a combination of LZ4_setStreamDecode() followed by LZ4_decompress_*_continue()
They are stand-alone, and don't need an LZ4_streamDecode_t structure.
"""
function LZ4_decompress_safe_usingDict(src, dst, srcSize, dstCapcity, dictStart, dictSize)
    ccall((:LZ4_decompress_safe_usingDict, liblz4), Int32, (Ptr{UInt8}, Ptr{UInt8}, Int32, Int32, Ptr{UInt8}, Int32), src, dst, srcSize, dstCapcity, dictStart, dictSize)
end

"""
    LZ4_decompress_*_usingDict()

These decoding functions work the same as
a combination of LZ4_setStreamDecode() followed by LZ4_decompress_*_continue()
They are stand-alone, and don't need an LZ4_streamDecode_t structure.
"""
function LZ4_decompress_fast_usingDict(src, dst, originalSize, dictStart, dictSize)
    ccall((:LZ4_decompress_safe_usingDict, liblz4), Int32, (Ptr{UInt8}, Ptr{UInt8}, Int32, Ptr{UInt8}, Int32), src, dst, originalSize, dictStart, dictSize)
end
