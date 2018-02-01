
include("lz4frame.jl")
using TranscodingStreams

const BUF_SIZE = 16*1024
const LZ4_FOOTER_SIZE = 4

struct LZ4Compressor <: TranscodingStreams.Codec
    ctx::Ref{Ptr{LZ4F_cctx}}
    prefs::Ref{LZ4F_preferences_t}
    header::Ref{Memory}
end

function LZ4Compressor()
    ctx = Ref{Ptr{LZ4F_cctx}}(C_NULL)
    frame = LZ4F_frameInfo_t(LZ4F_max256KB, LZ4F_blockLinked, LZ4F_noContentChecksum, LZ4F_frame, 0, 0, LZ4F_noBlockChecksum)
    prefs = Ref(LZ4F_preferences_t(frame, 0,0, (0,0,0,0)))
    return LZ4Compressor(ctx, prefs, Ref(Memory(pointer(""), 0)))
end

const LZ4CompressorStream{S} = TranscodingStream{LZ4Compressor,S} where S<:IO

function LZ4CompressorStream(stream::IO)
    return TranscodingStream(LZ4Compressor(), stream)
end

function TranscodingStreams.expectedsize(codec::LZ4Compressor, input::Memory)::Int
    convert(Int, LZ4F_compressBound(input.size, codec.prefs))+ LZ4F_HEADER_SIZE_MAX + LZ4_FOOTER_SIZE
end

function TranscodingStreams.minoutsize(codec::LZ4Compressor, input::Memory)::Int
    LZ4F_HEADER_SIZE_MAX
end

function TranscodingStreams.initialize(codec::LZ4Compressor)::Void
    LZ4F_createCompressionContext(codec.ctx, LZ4F_getVersion())
    nothing
end

function TranscodingStreams.finalize(codec::LZ4Compressor)::Void
    LZ4F_freeCompressionContext(codec.ctx[])
    nothing
end

function TranscodingStreams.startproc(codec::LZ4Compressor, mode::Symbol, error::Error)::Symbol
    header = Vector{UInt8}(LZ4F_HEADER_SIZE_MAX)
    try
        headerSize = LZ4F_compressBegin(codec.ctx[], header, convert(Csize_t, LZ4F_HEADER_SIZE_MAX), codec.prefs)
        codec.header[] = Memory(pointer(header), headerSize)
        :ok
    catch err
        error[] = err
        :error
    end
end

function TranscodingStreams.process(codec::LZ4Compressor, input::Memory, output::Memory, error::Error)::Tuple{Int,Int,Symbol}
    data_read = 0
    data_written = 0
    if codec.header[].size>0
        unsafe_copy!(output.ptr, codec.header[].ptr, codec.header[].size)
        data_written = codec.header[].size
        codec.header[] = Memory(pointer(""),0)
    end

    try
        if input.size == 0
            data_written += LZ4F_compressEnd(codec.ctx[], output.ptr+data_written, output.size-data_written, C_NULL)
            (data_read, data_written, :end)
        else
            data_written += LZ4F_compressUpdate(codec.ctx[], output.ptr+data_written, output.size-data_written, input.ptr, input.size, C_NULL)
            (input.size, data_written, :ok)
        end

    catch err
        error[] = err
        (data_read, data_written, :error)
    end

end

function get_block_size(frameinfo)
    blocksize = frameinfo.blockSizeID
    if blocksize == LZ4F_default || blocksize == LZ4F_max64KB
        return 1 << 16
    elseif blocksize == LZ4F_max256KB
        return 1 << 18
    elseif blocksize == LZ4F_max1MB
        return 1 << 20
    elseif blocksize == LZ4F_max4MB
        return 1 << 22
    else 
        error("Impossible block size");
    end
end

struct LZ4Decompressor <: TranscodingStreams.Codec
    dctx::Ref{Ptr{LZ4F_dctx}}
end

function LZ4Decompressor()
    dctx = Ref{Ptr{LZ4F_dctx}}(C_NULL)
    return LZ4Decompressor(dctx)
end

const LZ4DecompressorStream{S} = TranscodingStream{LZ4Decompressor,S} where S<:IO

function LZ4DecompressorStream(stream::IO)
    return TranscodingStream(LZ4Decompressor(), stream)
end

function TranscodingStreams.initialize(codec::LZ4Decompressor)::Void
    LZ4F_createDecompressionContext(codec.dctx, LZ4F_getVersion())
    nothing
end

function TranscodingStreams.finalize(codec::LZ4Decompressor)::Void
    LZ4F_freeDecompressionContext(codec.dctx[])
    nothing
end

function TranscodingStreams.process(codec::LZ4Decompressor, input::Memory, output::Memory, error::Error)::Tuple{Int,Int,Symbol}
    data_read = 0
    data_written = 0
    
    try
        if input.size == 0
            (data_read, data_written, :end)
        else
            src_size = Ref{Csize_t}(input.size)
            dst_size = Ref{Csize_t}(output.size)
            LZ4F_decompress(codec.dctx[], output.ptr, dst_size, input.ptr, src_size, C_NULL)
            (src_size[], dst_size[], :ok)
        end

    catch err
        error[] = err
        (data_read, data_written, :error)
    end

end

# Based on sample code from https://github.com/lz4/lz4/blob/dev/examples/frameCompress.c
function compress_stream(in_stream::IO, out_stream::IO) 
    count_in = 0
    count_out = 0
    ctx = Ref{Ptr{LZ4F_cctx}}(C_NULL)
    try
        frame = LZ4F_frameInfo_t(LZ4F_max256KB, LZ4F_blockLinked, LZ4F_noContentChecksum, LZ4F_frame, 0, 0, LZ4F_noBlockChecksum)

        prefs = Ref(LZ4F_preferences_t(frame, 0,0, (0,0,0,0)))

        src = Vector{UInt8}(BUF_SIZE)
        frame_size = LZ4F_compressBound(BUF_SIZE, prefs)

        bufsize = frame_size + LZ4F_HEADER_SIZE_MAX + LZ4_FOOTER_SIZE
        buf = Vector{UInt8}(bufsize)

        LZ4F_createCompressionContext(ctx, LZ4F_getVersion())

        headerSize = LZ4F_compressBegin(ctx[], buf, bufsize, prefs)

        offset = count_out = headerSize

        while true 
            readSize = readbytes!(in_stream, src, BUF_SIZE)
            if readSize == 0
                break
            end
            count_in += readSize

            compressedSize = LZ4F_compressUpdate(ctx[], pointer(buf) + offset, bufsize - offset, pointer(src), (UInt)(readSize), C_NULL)
            
            offset += compressedSize
            count_out += compressedSize

            if bufsize - offset < frame_size + LZ4_FOOTER_SIZE
                writtenSize=0
                unsafe_write(out_stream, pointer(buf), offset)
                offset = 0
            end
        end

         compressedSize = LZ4F_compressEnd(ctx[], pointer(buf) + offset, bufsize - offset, C_NULL)
         
         offset += compressedSize
         count_out += compressedSize

        unsafe_write(out_stream, pointer(buf), offset)
        LZ4F_freeCompressionContext(ctx[])
    catch err
        LZ4F_freeCompressionContext(ctx[])
        rethrow(err)
    end
   
    (count_in, count_out)
end

function decompress_stream(in_stream::IO, out_stream::IO) 
        src = Vector{UInt8}(BUF_SIZE)
        dctx = Ref{Ptr{LZ4F_dctx}}(C_NULL)
    try
        LZ4F_createDecompressionContext(dctx, LZ4F_getVersion())

        ret = 1
        while (!eof(in_stream)) 
            src_size = Ref{Csize_t}(0)
            src_size[] = readbytes!(in_stream, src, BUF_SIZE)
            src_ptr = pointer(src)
            src_end = src_ptr + src_size[]
               
            frameinfo = Ref(LZ4F_frameInfo_t())
            ret = LZ4F_getFrameInfo(dctx[], frameinfo, src, src_size)
            
            dst_capacity = get_block_size(frameinfo[])
            
            dst = Vector{UInt8}(dst_capacity)
                
            src_ptr += src_size[]
            src_size = Ref{Csize_t}(src_end - src_ptr)
            
            while src_ptr != src_end && ret != 0
                dst_size = Ref{Csize_t}(dst_capacity)
                ret = LZ4F_decompress(dctx[], dst, dst_size, src_ptr, src_size, C_NULL)

                if dst_size[] != 0
                    unsafe_write(out_stream, pointer(dst), dst_size[])
                    
                end
                
                src_ptr += src_size[]
                src_size[] = src_end - src_ptr
            end
        end
        #Check that there isn't trailing input data after the frame.
        #It is valid to have multiple frames in the same file, but this example
        #doesn't support it.
        
        ret = readbytes!(in_stream, src, 1)
        
    catch err
        LZ4F_freeDecompressionContext(dctx[])
        rethrow(err)
    end
end





