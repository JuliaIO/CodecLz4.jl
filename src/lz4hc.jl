# Julia wrapper for header: /usr/local/include/lz4hc.h

struct LZ4_streamHC_t
	table::NTuple{LZ4_STREAMHCSIZE_SIZET, Csize_t}
end
LZ4_compress_HC(src, dst, srcSize, dstCapacity, compressionLevel) = ccall((:LZ4_compress_HC, "liblz4"), Int32, (Cstring, Cstring, Int32, Int32, Int32), src, dst, srcSize, dstCapacity, compressionLevel)
LZ4_compress_HC_extStateHC(state, src, dst, srcSize, maxDstSize, compressionLevel) = ccall((:LZ4_compress_HC_extStateHC, "liblz4"), Int32, (Ptr{Void}, Cstring, Cstring, Int32, Int32, Int32), state, src, dst, srcSize, maxDstSize, compressionLevel)
LZ4_sizeofStateHC() = ccall((:LZ4_sizeofStateHC, "liblz4"), Int32, ())
LZ4_createStreamHC() = ccall((:LZ4_createStreamHC, "liblz4"), Ptr{LZ4_streamHC_t}, ())
LZ4_freeStreamHC(streamHCPtr) = ccall((:LZ4_freeStreamHC, "liblz4"), Int32, (Ptr{LZ4_streamHC_t},), streamHCPtr)
LZ4_resetStreamHC(streamHCPtr, compressionLevel) = ccall((:LZ4_resetStreamHC, "liblz4"), Void, (Ptr{LZ4_streamHC_t}, Int32), streamHCPtr, compressionLevel)
LZ4_loadDictHC(streamHCPtr, dictionary, dictSize) = ccall((:LZ4_loadDictHC, "liblz4"), Int32, (Ptr{LZ4_streamHC_t}, Cstring, Int32), streamHCPtr, dictionary, dictSize)
LZ4_compress_HC_continue(streamHCPtr, src, dst, srcSize, maxDstSize) = ccall((:LZ4_compress_HC_extStateHC, "liblz4"), Int32, (Ptr{LZ4_streamHC_t}, Cstring, Cstring, Int32, Int32), streamHCPtr, safeBuffer, maxDictSize)
LZ4_saveDictHC(streamHCPtr, safeBuffer, maxDictSize) = ccall((:LZ4_saveDictHC, "liblz4"), Int32, (Ptr{LZ4_streamHC_t}, Cstring, Int32), streamHCPtr, dictionary, dictSize)
