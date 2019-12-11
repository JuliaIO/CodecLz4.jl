# Julia wrapper for header: /usr/local/include/lz4frame_static.h
# Automatically generated using Clang.jl wrap_c, version 0.0.0
# This is included for completeness and remains untested

function LZ4F_getErrorCode(functionResult::Csize_t)
    ccall((:LZ4F_getErrorCode, liblz4), Csize_t, (Csize_t,), functionResult)
end

"""
    LZ4_createCDict(dictBuffer, dictSize::Csize_t)

When compressing multiple messages / blocks with the same dictionary, it's recommended to load it just once.
LZ4_createCDict() will create a digested dictionary, ready to start future compression operations without startup delay.
LZ4_CDict can be created once and shared by multiple threads concurrently, since its usage is read-only.
`dictBuffer` can be released after LZ4_CDict creation, since its content is copied within CDict
"""
function LZ4F_createCDict(dictBuffer, dictSize::Csize_t)
    ccall((:LZ4F_createCDict, liblz4), Ptr{LZ4F_CDict}, (Ptr{Cvoid}, Csize_t), dictBuffer, dictSize)
end

function LZ4F_freeCDict(CDict)
    ccall((:LZ4F_freeCDict, liblz4), Cvoid, (Ptr{LZ4F_CDict},), CDict)
end

"""
    LZ4_compressFrame_usingCDict(dst, dstCapacity::Csize_t, src, srcSize::Csize_t, cdict, preferencesPtr)

Compress an entire srcBuffer into a valid LZ4 frame using a digested Dictionary.
If cdict==NULL, compress without a dictionary.
dstBuffer MUST be >= LZ4F_compressFrameBound(srcSize, preferencesPtr).
If this condition is not respected, function will fail (@return an errorCode).
The LZ4F_preferences_t structure is optional : you may provide NULL as argument,
but it's not recommended, as it's the only way to provide dictID in the frame header.
@return : number of bytes written into dstBuffer.
        or an error code if it fails (can be tested using LZ4F_isError())
 """
function LZ4F_compressFrame_usingCDict(dst, dstCapacity::Csize_t, src, srcSize::Csize_t, cdict, preferencesPtr)
    ccall((:LZ4F_compressFrame_usingCDict, liblz4), Csize_t, (Ptr{Cvoid}, Csize_t, Ptr{Cvoid}, Csize_t, Ptr{LZ4F_CDict}, Ptr{LZ4F_preferences_t}), dst, dstCapacity, src, srcSize, cdict, preferencesPtr)
end

"""
    LZ4F_compressBegin_usingCDict(cctx, dstBuffer, dstCapacity::Csize_t, cdict, prefsPtr)

Inits streaming dictionary compression, and writes the frame header into dstBuffer.
dstCapacity must be >= LZ4F_HEADER_SIZE_MAX bytes.
`prefsPtr` is optional : you may provide NULL as argument,
however, it's the only way to provide dictID in the frame header.
@return : number of bytes written into dstBuffer for the header,
          or an error code (which can be tested using LZ4F_isError())
"""
function LZ4F_compressBegin_usingCDict(cctx, dstBuffer, dstCapacity::Csize_t, cdict, prefsPtr)
    ccall((:LZ4F_compressBegin_usingCDict, liblz4), Csize_t, (Ptr{LZ4F_cctx}, Ptr{Cvoid}, Csize_t, Ptr{LZ4F_CDict}, Ptr{LZ4F_preferences_t}), cctx, dstBuffer, dstCapacity, cdict, prefsPtr)
end

"""
    LZ4F_decompress_usingDict(dctxPtr, dstBuffer, dstSizePtr, srcBuffer, srcSizePtr, dict, dictSize::Csize_t, decompressOptionsPtr)

Same as LZ4F_decompress(), using a predefined dictionary.
Dictionary is used "in place", without any preprocessing.
It must remain accessible throughout the entire frame decoding.
"""
function LZ4F_decompress_usingDict(dctxPtr, dstBuffer, dstSizePtr, srcBuffer, srcSizePtr, dict, dictSize::Csize_t, decompressOptionsPtr)
    ccall((:LZ4F_decompress_usingDict, liblz4), Csize_t, (Ptr{LZ4F_dctx}, Ptr{Cvoid}, Ptr{Csize_t}, Ptr{Cvoid}, Ptr{Csize_t}, Ptr{Cvoid}, Csize_t, Ptr{LZ4F_decompressOptions_t}), dctxPtr, dstBuffer, dstSizePtr, srcBuffer, srcSizePtr, dict, dictSize, decompressOptionsPtr)
end
