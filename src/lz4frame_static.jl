# Julia wrapper for header: /usr/local/include/lz4frame_static.h
# Automatically generated using Clang.jl wrap_c, version 0.0.0

function LZ4F_isError(code::Csize_t)
    ccall((:LZ4F_isError, "liblz4"), UInt32, (Csize_t,), code)
end

function LZ4F_getErrorName(code::Csize_t)
    ccall((:LZ4F_getErrorName, "liblz4"), Cstring, (Csize_t,), code)
end

function LZ4F_compressionLevel_max()
    ccall((:LZ4F_compressionLevel_max, "liblz4"), Cint, ())
end

function LZ4F_compressFrameBound(srcSize::Csize_t, preferencesPtr)
    ccall((:LZ4F_compressFrameBound, "liblz4"), Csize_t, (Csize_t, Ptr{LZ4F_preferences_t}), srcSize, preferencesPtr)
end

function LZ4F_compressFrame(dstBuffer, dstCapacity::Csize_t, srcBuffer, srcSize::Csize_t, preferencesPtr)
    ccall((:LZ4F_compressFrame, "liblz4"), Csize_t, (Ptr{Void}, Csize_t, Ptr{Void}, Csize_t, Ptr{LZ4F_preferences_t}), dstBuffer, dstCapacity, srcBuffer, srcSize, preferencesPtr)
end

function LZ4F_getVersion()
    ccall((:LZ4F_getVersion, "liblz4"), UInt32, ())
end

function LZ4F_createCompressionContext(cctxPtr, version::UInt32)
    ccall((:LZ4F_createCompressionContext, "liblz4"), Csize_t, (Ptr{Ptr{LZ4F_cctx}}, UInt32), cctxPtr, version)
end

function LZ4F_freeCompressionContext(cctx)
    ccall((:LZ4F_freeCompressionContext, "liblz4"), Csize_t, (Ptr{LZ4F_cctx},), cctx)
end

function LZ4F_compressBegin(cctx, dstBuffer, dstCapacity::Csize_t, prefsPtr)
    ccall((:LZ4F_compressBegin, "liblz4"), Csize_t, (Ptr{LZ4F_cctx}, Ptr{Void}, Csize_t, Ptr{LZ4F_preferences_t}), cctx, dstBuffer, dstCapacity, prefsPtr)
end

function LZ4F_compressBound(srcSize::Csize_t, prefsPtr)
    ccall((:LZ4F_compressBound, "liblz4"), Csize_t, (Csize_t, Ptr{LZ4F_preferences_t}), srcSize, prefsPtr)
end

function LZ4F_compressUpdate(cctx, dstBuffer, dstCapacity::Csize_t, srcBuffer, srcSize::Csize_t, cOptPtr)
    ccall((:LZ4F_compressUpdate, "liblz4"), Csize_t, (Ptr{LZ4F_cctx}, Ptr{Void}, Csize_t, Ptr{Void}, Csize_t, Ptr{LZ4F_compressOptions_t}), cctx, dstBuffer, dstCapacity, srcBuffer, srcSize, cOptPtr)
end

function LZ4F_flush(cctx, dstBuffer, dstCapacity::Csize_t, cOptPtr)
    ccall((:LZ4F_flush, "liblz4"), Csize_t, (Ptr{LZ4F_cctx}, Ptr{Void}, Csize_t, Ptr{LZ4F_compressOptions_t}), cctx, dstBuffer, dstCapacity, cOptPtr)
end

function LZ4F_compressEnd(cctx, dstBuffer, dstCapacity::Csize_t, cOptPtr)
    ccall((:LZ4F_compressEnd, "liblz4"), Csize_t, (Ptr{LZ4F_cctx}, Ptr{Void}, Csize_t, Ptr{LZ4F_compressOptions_t}), cctx, dstBuffer, dstCapacity, cOptPtr)
end

function LZ4F_createDecompressionContext(dctxPtr, version::UInt32)
    ccall((:LZ4F_createDecompressionContext, "liblz4"), Csize_t, (Ptr{Ptr{LZ4F_dctx}}, UInt32), dctxPtr, version)
end

function LZ4F_freeDecompressionContext(dctx)
    ccall((:LZ4F_freeDecompressionContext, "liblz4"), Csize_t, (Ptr{LZ4F_dctx},), dctx)
end

function LZ4F_getFrameInfo(dctx, frameInfoPtr, srcBuffer, srcSizePtr)
    ccall((:LZ4F_getFrameInfo, "liblz4"), Csize_t, (Ptr{LZ4F_dctx}, Ptr{LZ4F_frameInfo_t}, Ptr{Void}, Ptr{Csize_t}), dctx, frameInfoPtr, srcBuffer, srcSizePtr)
end

function LZ4F_decompress(dctx, dstBuffer, dstSizePtr, srcBuffer, srcSizePtr, dOptPtr)
    ccall((:LZ4F_decompress, "liblz4"), Csize_t, (Ptr{LZ4F_dctx}, Ptr{Void}, Ptr{Csize_t}, Ptr{Void}, Ptr{Csize_t}, Ptr{LZ4F_decompressOptions_t}), dctx, dstBuffer, dstSizePtr, srcBuffer, srcSizePtr, dOptPtr)
end

function LZ4F_resetDecompressionContext(dctx)
    ccall((:LZ4F_resetDecompressionContext, "liblz4"), Void, (Ptr{LZ4F_dctx},), dctx)
end

function LZ4F_getErrorCode(functionResult::Csize_t)
    ccall((:LZ4F_getErrorCode, "liblz4"), Csize_t, (Csize_t,), functionResult)
end

function LZ4F_createCDict(dictBuffer, dictSize::Csize_t)
    ccall((:LZ4F_createCDict, "liblz4"), Ptr{LZ4F_CDict}, (Ptr{Void}, Csize_t), dictBuffer, dictSize)
end

function LZ4F_freeCDict(CDict)
    ccall((:LZ4F_freeCDict, "liblz4"), Void, (Ptr{LZ4F_CDict},), CDict)
end

function LZ4F_compressFrame_usingCDict(dst, dstCapacity::Csize_t, src, srcSize::Csize_t, cdict, preferencesPtr)
    ccall((:LZ4F_compressFrame_usingCDict, "liblz4"), Csize_t, (Ptr{Void}, Csize_t, Ptr{Void}, Csize_t, Ptr{LZ4F_CDict}, Ptr{LZ4F_preferences_t}), dst, dstCapacity, src, srcSize, cdict, preferencesPtr)
end

function LZ4F_compressBegin_usingCDict(cctx, dstBuffer, dstCapacity::Csize_t, cdict, prefsPtr)
    ccall((:LZ4F_compressBegin_usingCDict, "liblz4"), Csize_t, (Ptr{LZ4F_cctx}, Ptr{Void}, Csize_t, Ptr{LZ4F_CDict}, Ptr{LZ4F_preferences_t}), cctx, dstBuffer, dstCapacity, cdict, prefsPtr)
end

function LZ4F_decompress_usingDict(dctxPtr, dstBuffer, dstSizePtr, srcBuffer, srcSizePtr, dict, dictSize::Csize_t, decompressOptionsPtr)
    ccall((:LZ4F_decompress_usingDict, "liblz4"), Csize_t, (Ptr{LZ4F_dctx}, Ptr{Void}, Ptr{Csize_t}, Ptr{Void}, Ptr{Csize_t}, Ptr{Void}, Csize_t, Ptr{LZ4F_decompressOptions_t}), dctxPtr, dstBuffer, dstSizePtr, srcBuffer, srcSizePtr, dict, dictSize, decompressOptionsPtr)
end

