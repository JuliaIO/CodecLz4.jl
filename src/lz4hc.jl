# Julia wrapper for header: /usr/local/include/lz4hc.h
# This is included for completeness and remains untested

const LZ4HC_CLEVEL_MIN = 3
const LZ4HC_CLEVEL_DEFAULT = 9
const LZ4HC_CLEVEL_OPT_MIN = 11
const LZ4HC_CLEVEL_MAX = 12

###########################
 # PRIVATE DEFINITIONS : Do Not Export
 # Do not use these definitions.
 # They are exposed to allow static allocation of `LZ4_streamHC_t`.
 # Using these definitions makes the code vulnerable to potential API break when upgrading LZ4
############################
const LZ4HC_DICTIONARY_LOGSIZE = 17
const LZ4HC_MAXD = 1 << LZ4HC_DICTIONARY_LOGSIZE
const LZ4HC_MAXD_MASK = LZ4HC_MAXD - 1
const LZ4HC_HASH_LOG = 15
const LZ4HC_HASHTABLESIZE = 1 << LZ4HC_HASH_LOG
const LZ4HC_HASH_MASK = LZ4HC_HASHTABLESIZE - 1
const LZ4_STREAMHCSIZE = 4LZ4HC_HASHTABLESIZE + 2LZ4HC_MAXD + 56
const LZ4_STREAMHCSIZE_SIZET = floor(Int, LZ4_STREAMHCSIZE / sizeof(Csize_t))

"""
    LZ4_compress_HC(src, dst, srcSize, dstCapacity, compressionLevel)

Compress data from `src` into `dst`, using the more powerful but slower "HC" algorithm.
`dst` must be already allocated.
Compression is guaranteed to succeed if `dstCapacity >= LZ4_compressBound(srcSize)`
Max supported `srcSize` value is LZ4_MAX_INPUT_SIZE (see "lz4.h")
`compressionLevel`: any value between 1 and LZ4HC_CLEVEL_MAX will work.
                    Values > LZ4HC_CLEVEL_MAX behave the same as LZ4HC_CLEVEL_MAX.
@return: the number of bytes written into 'dst'
           or 0 if compression fails.
"""
function LZ4_compress_HC(src, dst, srcSize, dstCapacity, compressionLevel)
    ccall((:LZ4_compress_HC, liblz4), Int32, (Cstring, Cstring, Int32, Int32, Int32), src, dst, srcSize, dstCapacity, compressionLevel)
end

"""
    LZ4_compress_HC_extStateHC(state, src, dst, srcSize, maxDstSize, compressionLevel)

Same as LZ4_compress_HC(), but using an externally allocated memory segment for `state`.
`state` size is provided by LZ4_sizeofStateHC().
Memory segment must be aligned on 8-bytes boundaries (which a normal malloc() should do properly).
"""
function LZ4_compress_HC_extStateHC(state, src, dst, srcSize, maxDstSize, compressionLevel)
    ccall((:LZ4_compress_HC_extStateHC, liblz4), Int32, (Ptr{Cvoid}, Cstring, Cstring, Int32, Int32, Int32), state, src, dst, srcSize, maxDstSize, compressionLevel)
end

function LZ4_sizeofStateHC()
    ccall((:LZ4_sizeofStateHC, liblz4), Int32, ())
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
    ccall((:LZ4_freeStreamHC, liblz4), Int32, (Ptr{LZ4_streamHC_t},), streamHCPtr)
end

function LZ4_resetStreamHC(streamHCPtr, compressionLevel)
    ccall((:LZ4_resetStreamHC, liblz4), Cvoid, (Ptr{LZ4_streamHC_t}, Int32), streamHCPtr, compressionLevel)
end

function LZ4_loadDictHC(streamHCPtr, dictionary, dictSize)
    ccall((:LZ4_loadDictHC, liblz4), Int32, (Ptr{LZ4_streamHC_t}, Cstring, Int32), streamHCPtr, dictionary, dictSize)
end

function LZ4_compress_HC_continue(streamHCPtr, src, dst, srcSize, maxDstSize)
    ccall((:LZ4_compress_HC_extStateHC, liblz4), Int32, (Ptr{LZ4_streamHC_t}, Cstring, Cstring, Int32, Int32), streamHCPtr, src, dst, srcSize, maxDstSize)
end

function LZ4_saveDictHC(streamHCPtr, safeBuffer, maxDictSize)
    ccall((:LZ4_saveDictHC, liblz4), Int32, (Ptr{LZ4_streamHC_t}, Cstring, Int32), streamHCPtr, safeBuffer, maxDictSize)
end
