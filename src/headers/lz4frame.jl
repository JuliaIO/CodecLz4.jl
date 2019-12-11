# Julia wrapper for header: /usr/local/include/lz4frame.h
# Automatically generated using Clang.jl wrap_c, version 0.0.0
# docstrings copied from /usr/local/include/lz4frame.h

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

const LZ4_MEMORY_USAGE = 14
const LZ4_MAX_INPUT_SIZE = 0x7e000000

const LZ4_HASHLOG = LZ4_MEMORY_USAGE - 2
const LZ4_HASHTABLESIZE = 1 << LZ4_MEMORY_USAGE
const LZ4_HASH_SIZE_U32 = 1 << LZ4_HASHLOG

const LZ4_STREAMDECODESIZE_U64 = 4
const LZ4_STREAMSIZE_U64 =((1 << (LZ4_MEMORY_USAGE-3)) + 4)

struct LZ4_stream_t
    table::NTuple{LZ4_STREAMSIZE_U64, Culonglong}
end

struct LZ4_streamDecode_t
    table::NTuple{LZ4_STREAMDECODESIZE_U64, Culonglong}
end

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

@enum BlockSizeID::Cuint default_size = 0 max64KB = 4 max256KB = 5 max1MB = 6 max4MB = 7
@enum BlockMode::Cuint block_linked = 0 block_independent = 1
@enum FrameType::Cuint normal_frame = 0 skippable_frame = 1

struct LZ4F_compressOptions_t
    stableSrc::Cuint
    reserved::NTuple{3, Cuint}
end

struct LZ4F_decompressOptions_t
    stableDst::Cuint
    reserved::NTuple{3, Cuint}
end

struct LZ4F_frameInfo_t
    blockSizeID::Cuint
    blockMode::Cuint
    contentChecksumFlag::Cuint
    frameType::Cuint
    contentSize::Culonglong
    dictID::Cuint
    blockChecksumFlag::Cuint
end

function LZ4F_frameInfo_t(;
    blocksizeid::BlockSizeID=default_size,
    blockmode::BlockMode=block_linked,
    contentchecksum::Bool=false,
    frametype::FrameType=normal_frame,
    contentsize::Integer=0,
    blockchecksum::Bool=false,
)
    LZ4F_frameInfo_t(Cuint(blocksizeid), Cuint(blockmode), Cuint(contentchecksum), Cuint(frametype), Culonglong(contentsize), Cuint(0), Cuint(blockchecksum))
end

struct LZ4F_preferences_t
    frameInfo::LZ4F_frameInfo_t
    compressionLevel::Cint
    autoFlush::Cuint
    reserved::NTuple{4, Cuint}
end

function LZ4F_preferences_t(frame_info::LZ4F_frameInfo_t; compressionlevel::Integer=0, autoflush::Bool=false)
    LZ4F_preferences_t(frame_info, Cint(compressionlevel), Cuint(autoflush), (0,0,0,0))
end

struct LZ4F_CDict
    dictContent::Ptr{Cvoid}
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

struct LZ4F_cctx
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
    lz4CtxPtr::Ptr{Cvoid}
    lz4CtxLevel::UInt32
end

struct LZ4F_dctx
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

function check_context_initialized(ctx::Ptr{LZ4F_cctx})
    if ctx == Ptr{LZ4F_cctx}(C_NULL)
        throw(LZ4Exception("LZ4F_cctx", "Uninitialized compression context"))
    end
end

function check_context_initialized(ctx::Ptr{LZ4F_dctx})
    if ctx == Ptr{LZ4F_dctx}(C_NULL)
        throw(LZ4Exception("LZ4F_dctx", "Uninitialized decompression context"))
    end
end

function LZ4F_isError(code::Csize_t)
    err = ccall((:LZ4F_isError, liblz4), UInt32, (Csize_t,), code)
    convert(Bool, err)
end

function LZ4F_getErrorName(code::Csize_t)
    str = ccall((:LZ4F_getErrorName, liblz4), Cstring, (Csize_t,), code)
    unsafe_string(str)
end

"""
Gets the current LZ4F version.
"""
function LZ4F_getVersion()
    ccall((:LZ4F_getVersion, liblz4), UInt32, ())
end

"""
The first thing to do is to create a compressionContext object, which will be used in all compression operations.
This is achieved using `LZ4F_createCompressionContext()`, which takes as argument a version.
The version provided MUST be the current version. It is intended to track potential version mismatch, notably when using DLL.
The function will provide a pointer to a fully allocated `LZ4F_cctx` object.
Will throw an error if there was an error during context creation.
"""
function LZ4F_createCompressionContext(cctxPtr::Ref{Ptr{LZ4F_cctx}}, version::UInt32)
    ret = ccall((:LZ4F_createCompressionContext, liblz4), Csize_t, (Ref{Ptr{LZ4F_cctx}}, UInt32), cctxPtr, version)
    if LZ4F_isError(ret)
        throw(LZ4Exception("LZ4F_createCompressionContext", LZ4F_getErrorName(ret)))
    end
    ret
end

"""
Releases the memory of a `LZ4F_cctx`.
"""
function LZ4F_freeCompressionContext(cctx::Ptr{LZ4F_cctx})
    ccall((:LZ4F_freeCompressionContext, liblz4), Csize_t, (Ptr{LZ4F_cctx},), cctx)
end

"""
Will write the frame header into `dstBuffer`.

`dstCapacity` must be >= `LZ4F_HEADER_SIZE_MAX` bytes.
`prefsPtr` is optional : you can provide `C_NULL` as argument, all preferences will then be set to default.
Returns the number of bytes written into `dstBuffer` for the header or throws an error.
 """
function LZ4F_compressBegin(cctx::Ptr{LZ4F_cctx}, dstBuffer, dstCapacity::Csize_t, prefsPtr::Ref{LZ4F_preferences_t})
    check_context_initialized(cctx)
    ret = ccall((:LZ4F_compressBegin, liblz4), Csize_t, (Ptr{LZ4F_cctx}, Ptr{Cvoid}, Csize_t, Ref{LZ4F_preferences_t}), cctx, dstBuffer, dstCapacity, prefsPtr)
    if LZ4F_isError(ret)
        throw(LZ4Exception("LZ4F_compressBegin" ,LZ4F_getErrorName(ret)))
    end
    ret
end

"""
Provides minimum `dstCapacity` for a given `srcSize` to guarantee operation success in worst case situations.

`prefsPtr` is optional : when `C_NULL` is provided, preferences will be set to cover worst case scenario.
Result is always the same for a `srcSize` and `prefsPtr`, so it can be trusted to size reusable buffers.
When `srcSize==0`, `LZ4F_compressBound()` provides an upper bound for `LZ4F_flush()` and `LZ4F_compressEnd()` operations.
"""
function LZ4F_compressBound(srcSize::Csize_t, prefsPtr::Ref{LZ4F_preferences_t})
    ccall((:LZ4F_compressBound, liblz4), Csize_t, (Csize_t, Ref{LZ4F_preferences_t}), srcSize, prefsPtr)
end

"""
Can be called repetitively to compress as much data as necessary.

An important rule is that `dstCapacity` MUST be large enough to ensure operation success even in worst case situations.
This value is provided by `LZ4F_compressBound()`.
If this condition is not respected, `LZ4F_compress()` will fail.
LZ4F_compressUpdate() doesn't guarantee error recovery. When an error occurs, compression context must be freed or resized.
`cOptPtr` is optional : `C_NULL` can be provided, in which case all options are set to default.
Returns the number of bytes written into `dstBuffer` (it can be zero, meaning input data was just buffered).
or throws an error if it fails.
 """
function LZ4F_compressUpdate(cctx::Ptr{LZ4F_cctx}, dstBuffer, dstCapacity::Csize_t, srcBuffer, srcSize::Csize_t, cOptPtr)
    check_context_initialized(cctx)
    ret = ccall((:LZ4F_compressUpdate, liblz4), Csize_t, (Ptr{LZ4F_cctx}, Ptr{Cvoid}, Csize_t, Ptr{Cvoid}, Csize_t, Ptr{LZ4F_compressOptions_t}), cctx, dstBuffer, dstCapacity, srcBuffer, srcSize, cOptPtr)
    if LZ4F_isError(ret)
        throw(LZ4Exception("LZ4F_compressUpdate", LZ4F_getErrorName(ret)))
    end
    ret
end

"""
When data must be generated and sent immediately, without waiting for a block to be completely filled,
it's possible to call `LZ4_flush()`. It will immediately compress any data buffered within `cctx`.
`dstCapacity` must be large enough to ensure the operation will be successful.
`cOptPtr` is optional : it's possible to provide `C_NULL`, all options will be set to default.
Returns the number of bytes written into `dstBuffer` (it can be zero, which means there was no data stored within `cctx`)
or throws an error if it fails.
"""
function LZ4F_flush(cctx::Ptr{LZ4F_cctx}, dstBuffer, dstCapacity::Csize_t, cOptPtr)
    check_context_initialized(cctx)
    ret = ccall((:LZ4F_flush, liblz4), Csize_t, (Ptr{LZ4F_cctx}, Ptr{Cvoid}, Csize_t, Ptr{LZ4F_compressOptions_t}), cctx, dstBuffer, dstCapacity, cOptPtr)
    if LZ4F_isError(ret)
        throw(LZ4Exception("LZ4F_flush", LZ4F_getErrorName(ret)))
    end
    ret
end

"""
Invoke to properly finish an LZ4 frame.

It will flush whatever data remained within `cctx` (like `LZ4_flush()`)
and properly finalize the frame, with an endMark and a checksum.
`cOptPtr` is optional : `C_NULL` can be provided, in which case all options will be set to default.
Returns the number of bytes written into `dstBuffer` (necessarily >= 4 (endMark), or 8 if optional frame checksum is enabled)
or throws an error if it fails (which can be tested using `LZ4F_isError()`)
A successful call to `LZ4F_compressEnd()` makes `cctx` available again for another compression task.
"""
function LZ4F_compressEnd(cctx::Ptr{LZ4F_cctx}, dstBuffer, dstCapacity::Csize_t, cOptPtr)
    check_context_initialized(cctx)
    ret = ccall((:LZ4F_compressEnd, liblz4), Csize_t, (Ptr{LZ4F_cctx}, Ptr{Cvoid}, Csize_t, Ptr{LZ4F_compressOptions_t}), cctx, dstBuffer, dstCapacity, cOptPtr)
    if LZ4F_isError(ret)
        throw(LZ4Exception("LZ4F_compressEnd", LZ4F_getErrorName(ret)))
    end
    ret
end

"""
Create an `LZ4F_dctx object`, to track all decompression operations.

The version provided MUST be the current LZ4F version.
The function provides a pointer to an allocated and initialized `LZ4F_dctx` object.
The the function throws an error if the `LZ4F_dctx` object cannot be initialized.
The `dctx` memory can be released using `LZ4F_freeDecompressionContext()`.
"""
function LZ4F_createDecompressionContext(dctxPtr::Ref{Ptr{LZ4F_dctx}}, version::UInt32)
    ret = ccall((:LZ4F_createDecompressionContext, liblz4), Csize_t, (Ref{Ptr{LZ4F_dctx}}, UInt32), dctxPtr, version)
    if LZ4F_isError(ret)
        throw(LZ4Exception("LZ4F_createDecompressionContext", LZ4F_getErrorName(ret)))
    end
    ret
end

"""
Frees the decompressionContext.

The result of `LZ4F_freeDecompressionContext()` is indicative of the current state of decompressionContext when being released.
That is, it should be == 0 if decompression has been completed fully and correctly.
"""
function LZ4F_freeDecompressionContext(dctx::Ptr{LZ4F_dctx})
    ccall((:LZ4F_freeDecompressionContext, liblz4), Csize_t, (Ptr{LZ4F_dctx},), dctx)
end

"""
Extracts frame parameters (max blockSize, dictID, etc.).

Its usage is optional.
Extracted information is typically useful for allocation and dictionary.
This function works in 2 situations :
 - At the beginning of a new frame, in which case
   it will decode information from `srcBuffer`, starting the decoding process.
   Input size must be large enough to successfully decode the entire frame header.
   Frame header size is variable, but is guaranteed to be <= `LZ4F_HEADER_SIZE_MAX` bytes.
   It's allowed to provide more input data than this minimum.
 - After decoding has been started.
   In which case, no input is read, frame parameters are extracted from dctx.
 - If decoding has barely started, but not yet extracted information from header,
   `LZ4F_getFrameInfo()` will fail.
The number of bytes consumed from srcBuffer will be updated within `srcSizePtr` (necessarily <= original value).
Decompression must resume from (`srcBuffer` + `srcSizePtr`).
Returns an hint about how many `srcSize` bytes `LZ4F_decompress()` expects for next call or throws an error.

Note 1 : In case of error, dctx is not modified. Decoding operation can resume from beginning safely.
Note 2 : Frame parameters are *copied into* an already allocated `LZ4F_frameInfo_t` structure.
"""
function LZ4F_getFrameInfo(dctx::Ptr{LZ4F_dctx}, frameInfoPtr::Ref{LZ4F_frameInfo_t}, srcBuffer, srcSizePtr)
    check_context_initialized(dctx)
    ret = ccall((:LZ4F_getFrameInfo, liblz4), Csize_t, (Ptr{LZ4F_dctx}, Ref{LZ4F_frameInfo_t}, Ptr{Cvoid}, Ref{Csize_t}), dctx, frameInfoPtr, srcBuffer, srcSizePtr)
    if LZ4F_isError(ret)
        throw(LZ4Exception("LZ4F_getFrameInfo", LZ4F_getErrorName(ret)))
    end
    ret
end

"""
Call this function repetitively to regenerate compressed data from `srcBuffer`.

The function will read up to `srcSizePtr` bytes from `srcBuffer`,
and decompress data into `dstBuffer`, of capacity `dstSizePtr`.
The number of bytes consumed from `srcBuffer` will be written into `srcSizePtr` (necessarily <= original value).
The number of bytes decompressed into `dstBuffer` will be written into `dstSizePtr` (necessarily <= original value).
The function does not necessarily read all input bytes, so always check value in `srcSizePtr`.
Unconsumed source data must be presented again in subsequent invocations.

`dstBuffer` can freely change between each consecutive function invocation.
`dstBuffer` content will be overwritten.

Returns an hint of how many `srcSize` bytes `LZ4F_decompress()` expects for next call.
Schematically, it's the size of the current (or remaining) compressed block + header of next block.
Respecting the hint provides some small speed benefit, because it skips intermediate buffers.
This is just a hint though, it's always possible to provide any srcSize.

When a frame is fully decoded, returns 0 (no more data expected).
When provided with more bytes than necessary to decode a frame,
`LZ4F_decompress()` will stop reading exactly at end of current frame, and return 0.

If decompression failed, an error is thrown.
After a decompression error, the `dctx` context is not resumable.
Use `LZ4F_resetDecompressionContext()` to return to clean state.
After a frame is fully decoded, dctx can be used again to decompress another frame.
"""
function LZ4F_decompress(dctx::Ptr{LZ4F_dctx}, dstBuffer, dstSizePtr::Ref{Csize_t}, srcBuffer, srcSizePtr::Ref{Csize_t}, dOptPtr)
    check_context_initialized(dctx)
    ret = ccall((:LZ4F_decompress, liblz4), Csize_t, (Ptr{LZ4F_dctx}, Ptr{Cvoid}, Ref{Csize_t}, Ptr{Cvoid}, Ref{Csize_t}, Ptr{LZ4F_decompressOptions_t}), dctx, dstBuffer, dstSizePtr, srcBuffer, srcSizePtr, dOptPtr)
    if LZ4F_isError(ret)
        throw(LZ4Exception("LZ4F_decompress", LZ4F_getErrorName(ret)))
    end
    ret
end


"""
Re-initializes decompression context

In case of an error, the context is left in "undefined" state.
In which case, it's necessary to reset it, before re-using it.
This method can also be used to abruptly stop any unfinished decompression,
and start a new one using same context resources.
 """
function LZ4F_resetDecompressionContext(dctx::Ptr{LZ4F_dctx})
    check_context_initialized(dctx)
    ccall((:LZ4F_resetDecompressionContext, liblz4), Cvoid, (Ptr{LZ4F_dctx},), dctx)
end

