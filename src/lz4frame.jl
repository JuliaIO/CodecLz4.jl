# Julia wrapper for header: /usr/local/include/lz4frame.h
# Automatically generated using Clang.jl wrap_c, version 0.0.0
include("orig_lz4.jl")
include("lz4hc.jl")

struct LZ4F_compressOptions_t
    stableSrc::Cuint
    reserved::NTuple{3, Cuint}
end

mutable struct LZ4F_frameInfo_t
    blockSizeID::Cuint         
    blockMode::Cuint           
    contentChecksumFlag::Cuint
    frameType::Cuint
    contentSize::Culonglong
    dictID::Cuint
    blockChecksumFlag::Cuint
end

LZ4F_frameInfo_t() = LZ4F_frameInfo_t(0,0,0,0,0,0,0)

mutable struct LZ4F_preferences_t
    frameInfo::LZ4F_frameInfo_t
    compressionLevel::Cint   
    autoFlush::Cuint         
    reserved::NTuple{4, Cuint}          
end

LZ4F_preferences_t() = LZ4F_preferences_t(LZ4F_frameInfo_t(), 0, 1, (0,0,0,0))

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
    dStage::Cuint
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
    err = ccall((:LZ4F_isError, "liblz4"), UInt32, (Csize_t,), code)
    convert(Bool, err)
end

function LZ4F_getErrorName(code::Csize_t)
    str = ccall((:LZ4F_getErrorName, "liblz4"), Cstring, (Csize_t,), code)
    unsafe_string(str)
end

function LZ4F_compressionLevel_max()
    ccall((:LZ4F_compressionLevel_max, "liblz4"), Cint, ())
end

function LZ4F_compressFrameBound(srcSize::Csize_t, preferencesPtr)
    ccall((:LZ4F_compressFrameBound, "liblz4"), Csize_t, (Csize_t, Ref{LZ4F_preferences_t}), srcSize, preferencesPtr)
end

function LZ4F_compressFrame(dstBuffer, dstCapacity::Csize_t, srcBuffer, srcSize::Csize_t, preferencesPtr)
    ccall((:LZ4F_compressFrame, "liblz4"), Csize_t, (Ptr{Void}, Csize_t, Ptr{Void}, Csize_t, Ref{LZ4F_preferences_t}), dstBuffer, dstCapacity, srcBuffer, srcSize, preferencesPtr)
end

function LZ4F_getVersion()
    ccall((:LZ4F_getVersion, "liblz4"), UInt32, ())
end

function LZ4F_createCompressionContext(cctxPtr, version::UInt32)
    ccall((:LZ4F_createCompressionContext, "liblz4"), Csize_t, (Ref{Ptr{LZ4F_cctx}}, UInt32), cctxPtr, version)
end

function LZ4F_freeCompressionContext(cctx)
    ccall((:LZ4F_freeCompressionContext, "liblz4"), Csize_t, (Ptr{LZ4F_cctx},), cctx)
end

function LZ4F_compressBegin(cctx, dstBuffer, dstCapacity::Csize_t, prefsPtr)
    ccall((:LZ4F_compressBegin, "liblz4"), Csize_t, (Ptr{LZ4F_cctx}, Ptr{Void}, Csize_t, Ref{LZ4F_preferences_t}), cctx, dstBuffer, dstCapacity, prefsPtr)
end

function LZ4F_compressBound(srcSize::Csize_t, prefsPtr)
    ccall((:LZ4F_compressBound, "liblz4"), Csize_t, (Csize_t, Ref{LZ4F_preferences_t}), srcSize, prefsPtr)
end

LZ4F_compressBound(srcSize::Int, prefsPtr)=LZ4F_compressBound(convert(Csize_t, srcSize), prefsPtr)

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
    ccall((:LZ4F_getFrameInfo, "liblz4"), Csize_t, (Ptr{LZ4F_dctx}, Ref{LZ4F_frameInfo_t}, Ptr{Void}, Ref{Csize_t}), dctx, frameInfoPtr, srcBuffer, srcSizePtr)
end

function LZ4F_decompress(dctx, dstBuffer, dstSizePtr, srcBuffer, srcSizePtr, dOptPtr)
    ccall((:LZ4F_decompress, "liblz4"), Csize_t, (Ptr{LZ4F_dctx}, Ptr{Void}, Ref{Csize_t}, Ptr{Void}, Ref{Csize_t}, Ptr{LZ4F_decompressOptions_t}), dctx, dstBuffer, dstSizePtr, srcBuffer, srcSizePtr, dOptPtr)
end

function LZ4F_resetDecompressionContext(dctx)
    ccall((:LZ4F_resetDecompressionContext, "liblz4"), Void, (Ptr{LZ4F_dctx},), dctx)
end

