# Julia wrapper for header: /usr/local/include/lz4hc.h

const LZ4HC_CLEVEL_MIN = 3
const LZ4HC_CLEVEL_DEFAULT = 9
const LZ4HC_CLEVEL_OPT_MIN = 11
const LZ4HC_CLEVEL_MAX = 12

"""
    LZ4_compress_HC(src, dst, srcSize, dstCapacity, compressionLevel)

Compress data from `src` into `dst`, using the more powerful but slower "HC" algorithm.
`dst` must be already allocated.
Compression is guaranteed to succeed if `dstCapacity >= LZ4_compressBound(srcSize)`
Max supported `srcSize` value is LZ4_MAX_INPUT_SIZE
`compressionLevel`: any value between 1 and LZ4HC_CLEVEL_MAX will work.
                    Values > LZ4HC_CLEVEL_MAX behave the same as LZ4HC_CLEVEL_MAX.
@return: the number of bytes written into 'dst'
           or 0 if compression fails.
"""
function LZ4_compress_HC(src, dst, srcSize, dstCapacity, compressionLevel)
    ret = ccall((:LZ4_compress_HC, liblz4), Cint, (Cstring, Cstring, Cint, Cint, Cint), src, dst, srcSize, dstCapacity, compressionLevel)
    check_compression_error(ret, "LZ4_compress_HC")
end

"""
    LZ4_createStreamHC()

Create memory for LZ4 HC streaming state.
Newly created states are automatically initialized.
Existing states can be re-used several times, using LZ4_resetStreamHC().
"""
function LZ4_createStreamHC()
    ccall((:LZ4_createStreamHC, liblz4), Ptr{LZ4_streamHC_t}, ())
end

"""
    LZ4_freeStreamHC(streamHCPtr)

Release memory for LZ4 HC streaming state.
Existing states can be re-used several times, using LZ4_resetStreamHC().
"""
function LZ4_freeStreamHC(streamHCPtr)
    ccall((:LZ4_freeStreamHC, liblz4), Cint, (Ptr{LZ4_streamHC_t},), streamHCPtr)
end

function LZ4_resetStreamHC(streamHCPtr, compressionLevel)
    ccall((:LZ4_resetStreamHC, liblz4), Cvoid, (Ptr{LZ4_streamHC_t}, Cint), streamHCPtr, compressionLevel)
end

"""
These functions compress data in successive blocks of any size, using previous blocks as dictionary.
One key assumption is that previous blocks (up to 64 KB) remain read-accessible while compressing next blocks.
There is an exception for ring buffers, which can be smaller than 64 KB.
Ring buffers scenario is automatically detected and handled by LZ4_compress_HC_continue().

Before starting compression, state must be properly initialized, using LZ4_resetStreamHC().
A first "fictional block" can then be designated as initial dictionary, using LZ4_loadDictHC() (Optional).

Then, use LZ4_compress_HC_continue() to compress each successive block.
Previous memory blocks (including initial dictionary when present) must remain accessible and unmodified during compression.
'dst' buffer should be sized to handle worst case scenarios (see LZ4_compressBound()), to ensure operation success.
Because in case of failure, the API does not guarantee context recovery, and context will have to be reset.
If `dst` buffer budget cannot be >= LZ4_compressBound(), consider using LZ4_compress_HC_continue_destSize() instead.

If, for any reason, previous data block can't be preserved unmodified in memory for next compression block,
you can save it to a more stable memory space, using LZ4_saveDictHC().
Return value of LZ4_saveDictHC() is the size of dictionary effectively saved into 'safeBuffer'
"""
function LZ4_compress_HC_continue(streamHCPtr, src, dst, srcSize, maxDstSize)
    ret = ccall((:LZ4_compress_HC_extStateHC, liblz4), Cint, (Ptr{LZ4_streamHC_t}, Cstring, Cstring, Cint, Cint), streamHCPtr, src, dst, srcSize, maxDstSize)
    check_compression_error(ret, "LZ4_compress_HC_continue")
end

# function LZ4_loadDictHC(streamHCPtr, dictionary, dictSize)
#     ccall((:LZ4_loadDictHC, liblz4), Cint, (Ptr{LZ4_streamHC_t}, Cstring, Cint), streamHCPtr, dictionary, dictSize)
# end

# function LZ4_saveDictHC(streamHCPtr, safeBuffer, maxDictSize)
#     ccall((:LZ4_saveDictHC, liblz4), Cint, (Ptr{LZ4_streamHC_t}, Cstring, Cint), streamHCPtr, safeBuffer, maxDictSize)
# end
