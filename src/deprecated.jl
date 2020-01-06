using Base: @deprecate_binding

# Deprecated as of v0.3.0
@deprecate_binding LZ4Compressor LZ4FrameCompressor
@deprecate_binding LZ4Decompressor LZ4FrameDecompressor
@deprecate_binding LZ4CompressorStream LZ4FrameCompressorStream
@deprecate_binding LZ4DecompressorStream LZ4FrameDecompressorStream
