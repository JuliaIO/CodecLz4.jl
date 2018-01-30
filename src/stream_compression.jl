# Based on sample code from https://github.com/lz4/lz4/blob/dev/examples/frameCompress.c
include("lz4frame.jl")

const BUF_SIZE = 16*1024
const LZ4_FOOTER_SIZE = 4

function compress_stream(filein::IO, out::IO) 
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
            readSize = readbytes!(filein, src, BUF_SIZE)
            if readSize == 0
                break
            end
            count_in += readSize

            compressedSize = LZ4F_compressUpdate(ctx[], pointer(buf) + offset, bufsize - offset, pointer(src), (UInt)(readSize), C_NULL)
            
            offset += compressedSize
            count_out += compressedSize

            if bufsize - offset < frame_size + LZ4_FOOTER_SIZE
                writtenSize=0
                unsafe_write(out, pointer(buf), offset)
                offset = 0
            end
        end

         compressedSize = LZ4F_compressEnd(ctx[], pointer(buf) + offset, bufsize - offset, C_NULL)
         
         offset += compressedSize
         count_out += compressedSize

        unsafe_write(out, pointer(buf), offset)
        LZ4F_freeCompressionContext(ctx[])
    catch err
        LZ4F_freeCompressionContext(ctx[])
        rethrow(err)
    end
   
    (count_in, count_out)
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

function decompress_stream(filein::IO, out::IO) 
        src = Vector{UInt8}(BUF_SIZE)
        dctx = Ref{Ptr{LZ4F_dctx}}(C_NULL)
    try
        LZ4F_createDecompressionContext(dctx, LZ4F_getVersion())

        ret = 1
        while (!eof(filein)) 
            srcSize = Ref{Csize_t}(0)
            srcSize[] = readbytes!(filein, src, BUF_SIZE)
            srcPtr = pointer(src)
            srcEnd = srcPtr + srcSize[]
               
            frameinfo = Ref(LZ4F_frameInfo_t())
            ret = LZ4F_getFrameInfo(dctx[], frameinfo, src, srcSize)
            
            dstCapacity = get_block_size(frameinfo[])
            
            dst = Vector{UInt8}(dstCapacity)
                
            srcPtr += srcSize[]
            srcSize = Ref{Csize_t}(srcEnd - srcPtr)
            
            while srcPtr != srcEnd && ret != 0
                dstSize = Ref{Csize_t}(dstCapacity)
                ret = LZ4F_decompress(dctx[], dst, dstSize, srcPtr, srcSize, C_NULL);

                if dstSize[] != 0
                    unsafe_write(out, pointer(dst), dstSize[])
                    
                end
                
                srcPtr += srcSize[]
                srcSize[] = srcEnd - srcPtr
            end
        end
        #Check that there isn't trailing input data after the frame.
        #It is valid to have multiple frames in the same file, but this example
        #doesn't support it.
        
        ret = readbytes!(filein, src, 1)
        
    catch err
        LZ4F_freeDecompressionContext(dctx[])
        rethrow(err)
    end
end
