# Julia wrapper for header: /usr/local/include/lz4.h
struct LZ4_stream_t 
    table::NTuple{LZ4_STREAMSIZE_U64, Culonglong}
end
struct LZ4_streamDecode_t 
    table::NTuple{LZ4_STREAMDECODESIZE_U64, Culonglong}
end

LZ4_compress_default(src, dst, srcsize, dstCapacity) = ccall((:LZ4_compress_default, "liblz4"), Int32, (Ptr{UInt8}, Ptr{UInt8}, Int32, Int32), src, dst, srcsize, dstCapacity)
LZ4_decompress_safe(src, dst, cmpsize, maxdcmpsize) = ccall((:LZ4_decompress_safe, "liblz4"), Int32, (Ptr{UInt8}, Ptr{UInt8}, Int32, Int32), src, dst, cmpsize, maxdcmpsize)
LZ4_compressBound(inputsize) = ccall((:LZ4_compressBound, "liblz4"), Int32, (Int32,), inputsize)
LZ4_compress_fast(src, dst, srcsize, dstCapacity, acceleration) = ccall((:LZ4_compress_fast, "liblz4"), Int32, (Ptr{UInt8}, Ptr{UInt8}, Int32, Int32, Int32), src, dst, srcsize, dstCapacity, acceleration)
LZ4_sizeofState() = ccall((:LZ4_sizeofState, "liblz4"), Int32, ())
LZ4_compress_fast_extState(state, src, dst, srcsize, dstCapacity, acceleration) = ccall((:LZ4_compress_fast_extState, "liblz4"), Int32, (Ptr{Void}, Ptr{UInt8}, Ptr{UInt8}, Int32, Int32, Int32), state, src, dst, srcsize, dstCapacity, acceleration)
LZ4_compress_destSize(src, dst, srcsize, dstCapacity) = ccall((:LZ4_compress_destSize, "liblz4"), Int32, (Ptr{UInt8}, Ptr{UInt8}, Ptr{Int32}, Int32), src, dst, srcsize, dstCapacity)
LZ4_decompress_fast(src, dst, origsize) = ccall((:LZ4_decompress_fast, "liblz4"), Int32, (Ptr{UInt8}, Ptr{UInt8}, Int32), src, dst, origsize)
LZ4_decompress_safe_partial(src, dst, cmpsize, tgtoutputsize, maxdcmpsize) = ccall((:LZ4_decompress_safe_partial, "liblz4"), Int32, (Ptr{UInt8}, Ptr{UInt8}, Int32, Int32, Int32), src, dst, cmpsize, tgtoutputsize, maxdcmpsize)
LZ4_createStream() = ccall((:LZ4_createStream, "liblz4"), Ptr{LZ4_stream_t}, ())
LZ4_freeStream(streamptr::Ptr{LZ4_stream_t}) = ccall((:LZ4_freeStream, "liblz4"), Int32, (Ptr{LZ4_stream_t},), streamptr)
LZ4_resetStream(streamptr) = ccall((:LZ4_resetStream, "liblz4"), Void, (Ptr{LZ4_stream_t},),streamptr)
LZ4_loadDict(streamptr, dictionary, dictSize) = ccall((:LZ4_loadDict, "liblz4"), Int32, (Ptr{LZ4_stream_t}, Ptr{UInt8}, Int32), streamptr, dictionary, dictSize)
LZ4_compress_fast_continue(streamptr, src, dst, srcSize, dstCapacity, acceleration) = ccall((:LZ4_compress_fast_continue, liblz4), Int32, (Ptr{LZ4_stream_t}, Ptr{UInt8}, Ptr{UInt8}, Int32, Int32, Int32), streamptr, src, dst, srcSize, dstCapacity, acceleration)
LZ4_saveDict(streamptr, safeBuffer, dictSize) = ccall((:LZ4_compress_fast_continue, "liblz4"), Int32, (Ptr{LZ4_stream_t}, Ptr{UInt8}, Int32), streamptr, safeBuffer, dictSize)
LZ4_createStreamDecode() = ccall((:LZ4_createStreamDecode, "liblz4"), Ptr{LZ4_streamDecode_t}, ())
LZ4_freeStreamDecode(LZ4_stream) = ccall((:LZ4_freeStreamDecode, "liblz4"), Int32, (Ptr{LZ4_streamDecode_t},), LZ4_stream)
LZ4_setStreamDecode(LZ4_streamDecode, dictionary, dictSize) = ccall((:LZ4_setStreamDecode, "liblz4"), Int32, (Ptr{LZ4_streamDecode_t}, Ptr{UInt8}, Int32), LZ4_streamDecode, dictionary, dictSize)
LZ4_decompress_safe_continue(LZ4_streamDecode, src, dst, srcSize, dstCapacity) = ccall((:LZ4_decompress_safe_continue, "liblz4"), Int32, (Ptr{LZ4_streamDecode_t}, Ptr{UInt8}, Ptr{UInt8}, Int32, Int32), LZ4_streamDecode, src, dst, srcSize, dstCapacity)
LZ4_decompress_fast_continue(LZ4_streamDecode, src, dst, originalSize) = ccall((:LZ4_decompress_fast_continue, "liblz4"), Int32, (Ptr{LZ4_streamDecode_t}, Ptr{UInt8}, Ptr{UInt8}, Int32), LZ4_streamDecode, src, dst, originalSize)
LZ4_decompress_safe_usingDict(src, dst, srcSize, dstCapcity, dictStart, dictSize) = ccall((:LZ4_decompress_safe_usingDict, "liblz4"), Int32, (Ptr{UInt8}, Ptr{UInt8}, Int32, Int32, Ptr{UInt8}, Int32), src, dst, srcSize, dstCapcity, dictStart, dictSize)
LZ4_decompress_fast_usingDict(src, dst, originalSize, dictStart, dictSize) = ccall((:LZ4_decompress_safe_usingDict, "liblz4"), Int32, (Ptr{UInt8}, Ptr{UInt8}, Int32, Ptr{UInt8}, Int32), src, dst, originalSize, dictStart, dictSize)

