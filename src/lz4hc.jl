# Julia wrapper for header: /usr/local/include/lz4hc.h

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

struct LZ4_streamHC_t
	table::NTuple{LZ4_STREAMHCSIZE_SIZET, Csize_t}
end
LZ4_compress_HC(src, dst, srcSize, dstCapacity, compressionLevel) = ccall((:LZ4_compress_HC, liblz4), Int32, (Cstring, Cstring, Int32, Int32, Int32), src, dst, srcSize, dstCapacity, compressionLevel)
LZ4_compress_HC_extStateHC(state, src, dst, srcSize, maxDstSize, compressionLevel) = ccall((:LZ4_compress_HC_extStateHC, liblz4), Int32, (Ptr{Void}, Cstring, Cstring, Int32, Int32, Int32), state, src, dst, srcSize, maxDstSize, compressionLevel)
LZ4_sizeofStateHC() = ccall((:LZ4_sizeofStateHC, liblz4), Int32, ())
LZ4_createStreamHC() = ccall((:LZ4_createStreamHC, liblz4), Ptr{LZ4_streamHC_t}, ())
LZ4_freeStreamHC(streamHCPtr) = ccall((:LZ4_freeStreamHC, liblz4), Int32, (Ptr{LZ4_streamHC_t},), streamHCPtr)
LZ4_resetStreamHC(streamHCPtr, compressionLevel) = ccall((:LZ4_resetStreamHC, liblz4), Void, (Ptr{LZ4_streamHC_t}, Int32), streamHCPtr, compressionLevel)
LZ4_loadDictHC(streamHCPtr, dictionary, dictSize) = ccall((:LZ4_loadDictHC, liblz4), Int32, (Ptr{LZ4_streamHC_t}, Cstring, Int32), streamHCPtr, dictionary, dictSize)
LZ4_compress_HC_continue(streamHCPtr, src, dst, srcSize, maxDstSize) = ccall((:LZ4_compress_HC_extStateHC, liblz4), Int32, (Ptr{LZ4_streamHC_t}, Cstring, Cstring, Int32, Int32), streamHCPtr, safeBuffer, maxDictSize)
LZ4_saveDictHC(streamHCPtr, safeBuffer, maxDictSize) = ccall((:LZ4_saveDictHC, liblz4), Int32, (Ptr{LZ4_streamHC_t}, Cstring, Int32), streamHCPtr, dictionary, dictSize)
