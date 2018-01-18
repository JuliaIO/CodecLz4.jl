__precompile__()
module LZ4
export LZ4_createStream, LZ4_freeStream
export LZ4_compress_default, LZ4_compress_fast, LZ4_compressBound
export LZ4_decompress_safe

export LZ4F_getVersion, LZ4F_isError, LZ4F_getErrorName	
export LZ4F_cctx, LZ4F_createCompressionContext,  LZ4F_freeCompressionContext
export LZ4F_compressBound, LZ4F_preferences_t
export LZ4F_compressBegin, LZ4F_compressUpdate, LZ4F_flush, LZ4F_compressEnd
export LZ4F_dctx, LZ4F_createDecompressionContext, LZ4F_freeDecompressionContext
export LZ4F_decompress, LZ4F_resetDecompressionContext
export LZ4F_frameInfo_t, LZ4F_getFrameInfo
export LZ4F_HEADER_SIZE_MAX, LZ4F_compressionLevel_max
export LZ4F_compressFrameBound, LZ4F_compressFrame

include("lz4_h.jl")
#include("orig_lz4.jl")
#include("lz4hc.jl")
include("lz4frame.jl")
#include("lz4frame_static.jl")
end
