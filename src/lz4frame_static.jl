# Julia wrapper for header: /usr/local/include/lz4frame_static.h
# Automatically generated using Clang.jl wrap_c, version 0.0.0

function LZ4F_getErrorCode(functionResult::Csize_t)
    ccall((:LZ4F_getErrorCode, liblz4), Csize_t, (Csize_t,), functionResult)
end

function LZ4F_createCDict(dictBuffer, dictSize::Csize_t)
    ccall((:LZ4F_createCDict, liblz4), Ptr{LZ4F_CDict}, (Ptr{Void}, Csize_t), dictBuffer, dictSize)
end

function LZ4F_freeCDict(CDict)
    ccall((:LZ4F_freeCDict, liblz4), Void, (Ptr{LZ4F_CDict},), CDict)
end

function LZ4F_compressFrame_usingCDict(dst, dstCapacity::Csize_t, src, srcSize::Csize_t, cdict, preferencesPtr)
    ccall((:LZ4F_compressFrame_usingCDict, liblz4), Csize_t, (Ptr{Void}, Csize_t, Ptr{Void}, Csize_t, Ptr{LZ4F_CDict}, Ptr{LZ4F_preferences_t}), dst, dstCapacity, src, srcSize, cdict, preferencesPtr)
end

function LZ4F_compressBegin_usingCDict(cctx, dstBuffer, dstCapacity::Csize_t, cdict, prefsPtr)
    ccall((:LZ4F_compressBegin_usingCDict, liblz4), Csize_t, (Ptr{LZ4F_cctx}, Ptr{Void}, Csize_t, Ptr{LZ4F_CDict}, Ptr{LZ4F_preferences_t}), cctx, dstBuffer, dstCapacity, cdict, prefsPtr)
end

function LZ4F_decompress_usingDict(dctxPtr, dstBuffer, dstSizePtr, srcBuffer, srcSizePtr, dict, dictSize::Csize_t, decompressOptionsPtr)
    ccall((:LZ4F_decompress_usingDict, liblz4), Csize_t, (Ptr{LZ4F_dctx}, Ptr{Void}, Ptr{Csize_t}, Ptr{Void}, Ptr{Csize_t}, Ptr{Void}, Csize_t, Ptr{LZ4F_decompressOptions_t}), dctxPtr, dstBuffer, dstSizePtr, srcBuffer, srcSizePtr, dict, dictSize, decompressOptionsPtr)
end

