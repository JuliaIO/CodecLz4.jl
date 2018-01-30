# Julia wrapper for header: /usr/local/include/lz4frame.h
# Automatically generated using Clang.jl wrap_c, version 0.0.0
include("orig_lz4.jl")
include("lz4hc.jl")

# Constants
const LZ4F_VERSION = 100
const LZ4F_HEADER_SIZE_MAX = 19

# Block Size
const LZ4F_default = (UInt32)(0)
const LZ4F_max64KB = (UInt32)(4)
const LZ4F_max256KB = (UInt32)(5)
const LZ4F_max1MB = (UInt32)(6)
const LZ4F_max4MB = (UInt32)(7)

# Block Mode
const LZ4F_blockLinked = (UInt32)(0)
const LZ4F_blockIndependent = (UInt32)(1)

# Content Checksum Flag
const LZ4F_noContentChecksum = (UInt32)(0)
const LZ4F_contentChecksumEnabled = (UInt32)(1)

# Block Checksum Flag
const LZ4F_noBlockChecksum = (UInt32)(0)
const LZ4F_blockChecksumEnabled = (UInt32)(1)

# Frame Type
const LZ4F_frame = (UInt32)(0)
const LZ4F_skippableFrame = (UInt32)(1)

# Error Codes
const LZ4F_OK_NoError = (UInt32)(0)
const LZ4F_ERROR_GENERIC = (UInt32)(1)
const LZ4F_ERROR_maxBlockSize_invalid = (UInt32)(2)
const LZ4F_ERROR_blockMode_invalid = (UInt32)(3)
const LZ4F_ERROR_contentChecksumFlag_invalid = (UInt32)(4)
const LZ4F_ERROR_compressionLevel_invalid = (UInt32)(5)
const LZ4F_ERROR_headerVersion_wrong = (UInt32)(6)
const LZ4F_ERROR_blockChecksum_invalid = (UInt32)(7)
const LZ4F_ERROR_reservedFlag_set = (UInt32)(8)
const LZ4F_ERROR_allocation_failed = (UInt32)(9)
const LZ4F_ERROR_srcSize_tooLarge = (UInt32)(10)
const LZ4F_ERROR_dstMaxSize_tooSmall = (UInt32)(11)
const LZ4F_ERROR_frameHeader_incomplete = (UInt32)(12)
const LZ4F_ERROR_frameType_unknown = (UInt32)(13)
const LZ4F_ERROR_frameSize_wrong = (UInt32)(14)
const LZ4F_ERROR_srcPtr_wrong = (UInt32)(15)
const LZ4F_ERROR_decompressionFailed = (UInt32)(16)
const LZ4F_ERROR_headerChecksum_invalid = (UInt32)(17)
const LZ4F_ERROR_contentChecksum_invalid = (UInt32)(18)
const LZ4F_ERROR_frameDecoding_alreadyStarted = (UInt32)(19)
const LZ4F_ERROR_maxCode = (UInt32)(20)

struct LZ4F_compressOptions_t
    stableSrc::Cuint
    reserved::NTuple{3, Cuint}
end

struct LZ4F_frameInfo_t
    blockSizeID::UInt32         
    blockMode::Cuint           
    contentChecksumFlag::Cuint
    frameType::Cuint
    contentSize::Culonglong
    dictID::Cuint
    blockChecksumFlag::Cuint
end

LZ4F_frameInfo_t() = LZ4F_frameInfo_t(LZ4F_default, LZ4F_blockLinked, LZ4F_noContentChecksum, 
                                            LZ4F_frame, 0, 0, LZ4F_noBlockChecksum)

struct LZ4F_preferences_t
    frameInfo::LZ4F_frameInfo_t
    compressionLevel::Cint   
    autoFlush::Cuint         
    reserved::NTuple{4, Cuint}          
end

LZ4F_preferences_t() = LZ4F_preferences_t(LZ4F_frameInfo_t(), 0, 0, (0,0,0,0))

struct LZ4F_CDict
    dictContent::Ptr{Void}
    fastCtx::Ptr{LZ4_stream_t}
    HCCtx::Ptr{LZ4_streamHC_t}
end

struct XXH32_state_t
   total_len_32::Cuint
   large_len::Cuint
   v1::Cuint
   v2::Cuint
   v3::Cuint
   v4::Cuint
   mem32::NTuple{4,UInt32}
   memsize::Cuint
   reserved::Cuint
end

mutable struct LZ4F_cctx
    prefs::LZ4F_preferences_t
    version::UInt32
    cStage::UInt32
    cdict::Ptr{LZ4F_CDict}
    maxBlockSize::Csize_t
    maxBufferSize::Csize_t
    tmpBuff::Ptr{Cuchar}
    tmpIn::Ptr{Cuchar}
    tmpInSize::Csize_t
    totalInSize::UInt64
    xxh::XXH32_state_t
    lz4CtxPtr::Ptr{Void}
    lz4CtxLevel::UInt32   
end 

mutable struct LZ4F_dctx 
    frameInfo::LZ4F_frameInfo_t
    version::UInt32
    dStage::UInt32
    frameRemainingSize::UInt64
    maxBlockSize::Csize_t
    maxBufferSize::Csize_t
    tmpIn::Ptr{Cuchar}
    tmpInSize::Csize_t
    tmpInTarget::Csize_t
    tmpOutBuffer::Ptr{Cuchar}
    dict::Ptr{Cuchar}
    dictSize::Csize_t
    tmpOut::Ptr{Cuchar}
    tmpOutSize::Csize_t
    tmpOutStart::Csize_t
    xxh::XXH32_state_t
    blockChecksum::XXH32_state_t
    header::NTuple{LZ4F_HEADER_SIZE_MAX, Cuchar}
end

struct LZ4F_decompressOptions_t
    stableDst::Cuint
    reserved::NTuple{3, Cuint}
end

function LZ4F_isError(code::Csize_t)
    err = ccall((:LZ4F_isError, liblz4), UInt32, (Csize_t,), code)
    convert(Bool, err)
end

function LZ4F_getErrorName(code::Csize_t)
    str = ccall((:LZ4F_getErrorName, liblz4), Cstring, (Csize_t,), code)
    unsafe_string(str)
end

function LZ4F_compressionLevel_max()
    ccall((:LZ4F_compressionLevel_max, liblz4), Cint, ())
end

function LZ4F_compressFrameBound(srcSize::Csize_t, preferencesPtr::Ref{LZ4F_preferences_t})
    ccall((:LZ4F_compressFrameBound, liblz4), Csize_t, (Csize_t, Ref{LZ4F_preferences_t}), srcSize, preferencesPtr)
end

function LZ4F_compressFrame(dstBuffer, dstCapacity::Csize_t, srcBuffer, srcSize::Csize_t, preferencesPtr::Ref{LZ4F_preferences_t})
    ret = ccall((:LZ4F_compressFrame, liblz4), Csize_t, (Ptr{Void}, Csize_t, Ptr{Void}, Csize_t, Ref{LZ4F_preferences_t}), dstBuffer, dstCapacity, srcBuffer, srcSize, preferencesPtr)
    if LZ4F_isError(ret)
        error("LZ4F_compressFrame: " * LZ4F_getErrorName(ret))
    end
    ret
end

function LZ4F_getVersion()
    ccall((:LZ4F_getVersion, liblz4), UInt32, ())
end

function LZ4F_createCompressionContext(cctxPtr::Ref{Ptr{LZ4F_cctx}}, version::UInt32)
    ret = ccall((:LZ4F_createCompressionContext, liblz4), Csize_t, (Ref{Ptr{LZ4F_cctx}}, UInt32), cctxPtr, version)
    if LZ4F_isError(ret)
        error("LZ4F_createCompressionContext: " * LZ4F_getErrorName(ret))
    end
    ret
end

function LZ4F_freeCompressionContext(cctx::Ptr{LZ4F_cctx})
    ccall((:LZ4F_freeCompressionContext, liblz4), Csize_t, (Ptr{LZ4F_cctx},), cctx)
end

function LZ4F_compressBegin(cctx::Ptr{LZ4F_cctx}, dstBuffer, dstCapacity::Csize_t, prefsPtr::Ref{LZ4F_preferences_t})
    ret = ccall((:LZ4F_compressBegin, liblz4), Csize_t, (Ptr{LZ4F_cctx}, Ptr{Void}, Csize_t, Ref{LZ4F_preferences_t}), cctx, dstBuffer, dstCapacity, prefsPtr)
    if LZ4F_isError(ret)
        error("LZ4F_compressBegin: " * LZ4F_getErrorName(ret))
    end
    ret
end

function LZ4F_compressBound(srcSize::Csize_t, prefsPtr::Ref{LZ4F_preferences_t})
    ccall((:LZ4F_compressBound, liblz4), Csize_t, (Csize_t, Ref{LZ4F_preferences_t}), srcSize, prefsPtr)
end

LZ4F_compressBound(srcSize::Int, prefsPtr::Ref{LZ4F_preferences_t})=LZ4F_compressBound(convert(Csize_t, srcSize), prefsPtr)

function LZ4F_compressUpdate(cctx::Ptr{LZ4F_cctx}, dstBuffer, dstCapacity::Csize_t, srcBuffer, srcSize::Csize_t, cOptPtr)
    ret = ccall((:LZ4F_compressUpdate, liblz4), Csize_t, (Ptr{LZ4F_cctx}, Ptr{Void}, Csize_t, Ptr{Void}, Csize_t, Ptr{LZ4F_compressOptions_t}), cctx, dstBuffer, dstCapacity, srcBuffer, srcSize, cOptPtr)
    if LZ4F_isError(ret)
        error("LZ4F_compressUpdate: " * LZ4F_getErrorName(ret))
    end
    ret
end

function LZ4F_flush(cctx::Ptr{LZ4F_cctx}, dstBuffer, dstCapacity::Csize_t, cOptPtr)
    ret = ccall((:LZ4F_flush, liblz4), Csize_t, (Ptr{LZ4F_cctx}, Ptr{Void}, Csize_t, Ptr{LZ4F_compressOptions_t}), cctx, dstBuffer, dstCapacity, cOptPtr)
    if LZ4F_isError(ret)
        error("LZ4F_flush: " * LZ4F_getErrorName(ret))
    end
    ret
end

function LZ4F_compressEnd(cctx::Ptr{LZ4F_cctx}, dstBuffer, dstCapacity::Csize_t, cOptPtr)
    ret = ccall((:LZ4F_compressEnd, liblz4), Csize_t, (Ptr{LZ4F_cctx}, Ptr{Void}, Csize_t, Ptr{LZ4F_compressOptions_t}), cctx, dstBuffer, dstCapacity, cOptPtr)
    if LZ4F_isError(ret)
        error("LZ4F_compressEnd: " * LZ4F_getErrorName(ret))
    end
    ret
end

function LZ4F_createDecompressionContext(dctxPtr::Ref{Ptr{LZ4F_dctx}}, version::UInt32)
    ret = ccall((:LZ4F_createDecompressionContext, liblz4), Csize_t, (Ref{Ptr{LZ4F_dctx}}, UInt32), dctxPtr, version)
    if LZ4F_isError(ret)
        error("LZ4F_createDecompressionContext: " * LZ4F_getErrorName(ret))
    end
    ret
end

function LZ4F_freeDecompressionContext(dctx::Ptr{LZ4F_dctx})
    ccall((:LZ4F_freeDecompressionContext, liblz4), Csize_t, (Ptr{LZ4F_dctx},), dctx)
end

function LZ4F_getFrameInfo(dctx::Ptr{LZ4F_dctx}, frameInfoPtr::Ref{LZ4F_frameInfo_t}, srcBuffer, srcSizePtr)
    ret = ccall((:LZ4F_getFrameInfo, liblz4), Csize_t, (Ptr{LZ4F_dctx}, Ref{LZ4F_frameInfo_t}, Ptr{Void}, Ref{Csize_t}), dctx, frameInfoPtr, srcBuffer, srcSizePtr)
    if LZ4F_isError(ret)
        error("LZ4F_getFrameInfo: " * LZ4F_getErrorName(ret))
    end
    ret
end

function LZ4F_decompress(dctx::Ptr{LZ4F_dctx}, dstBuffer, dstSizePtr::Ref{Csize_t}, srcBuffer, srcSizePtr::Ref{Csize_t}, dOptPtr)
    ret = ccall((:LZ4F_decompress, liblz4), Csize_t, (Ptr{LZ4F_dctx}, Ptr{Void}, Ref{Csize_t}, Ptr{Void}, Ref{Csize_t}, Ptr{LZ4F_decompressOptions_t}), dctx, dstBuffer, dstSizePtr, srcBuffer, srcSizePtr, dOptPtr)
    if LZ4F_isError(ret)
        error("LZ4F_decompress: " * LZ4F_getErrorName(ret))
    end
    ret
end

function LZ4F_resetDecompressionContext(dctx::Ptr{LZ4F_dctx})
    ccall((:LZ4F_resetDecompressionContext, liblz4), Void, (Ptr{LZ4F_dctx},), dctx)
end

