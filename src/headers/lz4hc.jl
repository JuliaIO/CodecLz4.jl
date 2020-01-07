# Julia wrapper for header: /usr/local/include/lz4hc.h
# docstrings copied from /usr/local/include/lz4hc.h

const LZ4HC_CLEVEL_MIN = 3
const LZ4HC_CLEVEL_DEFAULT = 9
const LZ4HC_CLEVEL_OPT_MIN = 11
const LZ4HC_CLEVEL_MAX = 12

function check_initialized(stream::Ptr{LZ4_streamHC_t})
    if stream == Ptr{LZ4_streamHC_t}(C_NULL)
        throw(LZ4Exception("LZ4_streamHC_t", "Uninitialized compression stream"))
    end
end

"""
    LZ4_compress_HC(src, dst, srcsize, dstcapacity, compressionlevel)

Compress data from `src` into `dst`, using the more powerful but slower "HC" algorithm.
`dst` must be already allocated.
Compression is guaranteed to succeed if `dstcapacity >= LZ4_compressBound(srcsize)`
Max supported `srcsize` value is LZ4_MAX_INPUT_SIZE
`compressionlevel`: any value between 1 and LZ4HC_CLEVEL_MAX will work.
                    Values > LZ4HC_CLEVEL_MAX behave the same as LZ4HC_CLEVEL_MAX.
Returns the number of bytes written into `dst`
"""
function LZ4_compress_HC(src, dst, srcsize, dstcapacity, compressionlevel=LZ4HC_CLEVEL_DEFAULT)
    ret = ccall((:LZ4_compress_HC, liblz4), Cint, (Cstring, Cstring, Cint, Cint, Cint), src, dst, srcsize, dstcapacity, compressionlevel)
    check_compression_error(ret, "LZ4_compress_HC")
end

"""
    LZ4_createStreamHC()

Create memory for LZ4 HC streaming state.
Newly created states are automatically initialized.
Existing states can be re-used several times, using LZ4_resetStreamHC().
"""
function LZ4_createStreamHC()
    str = ccall((:LZ4_createStreamHC, liblz4), Ptr{LZ4_streamHC_t}, ())
    if str == C_NULL # Could not allocate memory
        throw(OutOfMemoryError())
    end
    return str
end

"""
    LZ4_freeStreamHC(streamptr)

Release memory for LZ4 HC streaming state.
Existing states can be re-used several times, using LZ4_resetStreamHC().
"""
function LZ4_freeStreamHC(streamptr::Ptr{LZ4_streamHC_t})
    ccall((:LZ4_freeStreamHC, liblz4), Cint, (Ptr{LZ4_streamHC_t},), streamptr)
end

function LZ4_resetStreamHC(streamptr::Ptr{LZ4_streamHC_t}, compressionlevel=LZ4HC_CLEVEL_DEFAULT)
    check_initialized(streamptr)
    ccall((:LZ4_resetStreamHC, liblz4), Cvoid, (Ptr{LZ4_streamHC_t}, Cint), streamptr, compressionlevel)
end

"""
    LZ4_compress_HC_continue(streamptr::Ptr{LZ4_streamHC_t}, src, dst, srcsize, maxdstsize)

Compress data in successive blocks of any size, using previous blocks as dictionary.
One key assumption is that previous blocks (up to 64 KB) remain read-accessible while compressing next blocks.
There is an exception for ring buffers, which can be smaller than 64 KB.
Ring buffers scenario is automatically detected and handled by LZ4_compress_HC_continue().

Before starting compression, state must be properly initialized, using LZ4_resetStreamHC().

Then, use LZ4_compress_HC_continue() to compress each successive block.
Previous memory blocks (including initial dictionary when present) must remain accessible and unmodified during compression.
`dst` buffer should be sized to handle worst case scenarios (see LZ4_compressBound()), to ensure operation success.
Because in case of failure, the API does not guarantee context recovery, and context will have to be reset.
"""
function LZ4_compress_HC_continue(streamptr::Ptr{LZ4_streamHC_t}, src, dst, srcsize, maxdstsize)
    check_initialized(streamptr)
    ret = ccall((:LZ4_compress_HC_extStateHC, liblz4), Cint, (Ptr{LZ4_streamHC_t}, Cstring, Cstring, Cint, Cint), streamptr, src, dst, srcsize, maxdstsize)
    check_compression_error(ret, "LZ4_compress_HC_continue")
end

# function LZ4_loadDictHC(streamHCPtr, dictionary, dictSize)
#     ccall((:LZ4_loadDictHC, liblz4), Cint, (Ptr{LZ4_streamHC_t}, Cstring, Cint), streamHCPtr, dictionary, dictSize)
# end

# function LZ4_saveDictHC(streamHCPtr, safeBuffer, maxDictSize)
#     ccall((:LZ4_saveDictHC, liblz4), Cint, (Ptr{LZ4_streamHC_t}, Cstring, Cint), streamHCPtr, safeBuffer, maxDictSize)
# end
