@testset "lz4frame" begin
     test_in = "Far out in the uncharted backwaters of the unfashionable end of the west-
 ern  spiral  arm  of  the  Galaxy  lies  a  small  unregarded  yellow  sun."
    test_size = convert(UInt, length(test_in))
    version = CodecLz4.LZ4F_getVersion()

    @testset "Errors" begin
        no_error = UInt(0)
        @test !CodecLz4.LZ4F_isError(no_error)
        @test CodecLz4.LZ4F_getErrorName(no_error) == "Unspecified error code"

        ERROR_GENERIC = typemax(UInt)
        @test CodecLz4.LZ4F_isError(ERROR_GENERIC)
        @test CodecLz4.LZ4F_getErrorName(ERROR_GENERIC) == "ERROR_GENERIC"
    end

    @testset "keywords" begin
        frame = CodecLz4.LZ4F_frameInfo_t()
        @test frame.blockSizeID == Cuint(default_size)
        @test frame.blockMode == Cuint(block_linked)
        @test frame.contentChecksumFlag == Cuint(0)
        @test frame.frameType == Cuint(normal_frame)
        @test frame.contentSize == Culonglong(0)
        @test frame.dictID == Cuint(0)
        @test frame.blockChecksumFlag == Cuint(0)

        prefs = CodecLz4.LZ4F_preferences_t(frame)

        @test prefs.frameInfo == frame
        @test prefs.compressionLevel == Cint(0)
        @test prefs.autoFlush == Cuint(0)
        @test prefs.reserved == (Cuint(0), Cuint(0), Cuint(0), Cuint(0))

        frame = CodecLz4.LZ4F_frameInfo_t(
            blocksizeid = max64KB,
            blockmode = block_independent,
            contentchecksum = true,
            blockchecksum = true,
            frametype = skippable_frame,
            contentsize = 100
            )

        @test frame.blockSizeID == Cuint(4)
        @test frame.blockMode == Cuint(1)
        @test frame.contentChecksumFlag == Cuint(1)
        @test frame.frameType == Cuint(1)
        @test frame.contentSize == Culonglong(100)
        @test frame.blockChecksumFlag == Cuint(1)

        prefs = CodecLz4.LZ4F_preferences_t(frame, compressionlevel=5, autoflush = true)

        @test prefs.frameInfo == frame
        @test prefs.compressionLevel == Cint(5)
        @test prefs.autoFlush == Cuint(1)
        @test prefs.reserved == (Cuint(0), Cuint(0), Cuint(0), Cuint(0))

    end

    @testset "CompressionCtx" begin
        ctx = Ref{Ptr{CodecLz4.LZ4F_cctx}}(C_NULL)

        @test_nowarn err = CodecLz4.LZ4F_createCompressionContext(ctx, version)
        @test err == 0

        @test_nowarn CodecLz4.check_context_initialized(ctx[])

        err = CodecLz4.LZ4F_freeCompressionContext(ctx[])
        @test err == 0
        @test !CodecLz4.LZ4F_isError(err)

        ctx = Ptr{CodecLz4.LZ4F_cctx}(C_NULL)
        @test_throws CodecLz4.LZ4Exception CodecLz4.check_context_initialized(ctx)
    end


    @testset "DecompressionCtx" begin
        dctx = Ref{Ptr{CodecLz4.LZ4F_dctx}}(C_NULL)

        @test_nowarn err = CodecLz4.LZ4F_createDecompressionContext(dctx, version)
        @test err == 0

        @test_nowarn CodecLz4.check_context_initialized(dctx[])

        @test_nowarn CodecLz4.LZ4F_resetDecompressionContext(dctx[])

        err = CodecLz4.LZ4F_freeDecompressionContext(dctx[])
        @test err == 0

        dctx = Ptr{CodecLz4.LZ4F_dctx}(C_NULL)
        @test_throws CodecLz4.LZ4Exception CodecLz4.check_context_initialized(dctx)
        @test_throws CodecLz4.LZ4Exception CodecLz4.LZ4F_resetDecompressionContext(dctx)

    end

    function test_decompress(origsize, buffer)
        @testset "Decompress" begin
            dctx = Ref{Ptr{CodecLz4.LZ4F_dctx}}(C_NULL)
            srcsize = Ref{Csize_t}(origsize)
            dstsize =  Ref{Csize_t}(8*1280)
            decbuffer = Vector{UInt8}(undef, 1280)

            frameinfo = Ref(CodecLz4.LZ4F_frameInfo_t())

            @test_nowarn err = CodecLz4.LZ4F_createDecompressionContext(dctx, version)

            @test_nowarn result = CodecLz4.LZ4F_getFrameInfo(dctx[], frameinfo, buffer, srcsize)
            @test srcsize[] > 0

            offset = srcsize[]
            srcsize[] = origsize - offset

            @test_nowarn result = CodecLz4.LZ4F_decompress(dctx[], decbuffer, dstsize, pointer(buffer) + offset, srcsize, C_NULL)
            @test srcsize[] > 0

            @test test_in == unsafe_string(pointer(decbuffer), dstsize[])

            result = CodecLz4.LZ4F_freeDecompressionContext(dctx[])
            @test !CodecLz4.LZ4F_isError(result)
        end

    end

    function test_invalid_decompress(origsize, buffer)
        @testset "DecompressInvalid" begin

            dctx = Ref{Ptr{CodecLz4.LZ4F_dctx}}(C_NULL)
            srcsize = Ref{Csize_t}(origsize)
            dstsize =  Ref{Csize_t}(1280)
            decbuffer = Vector{UInt8}(undef, 1280)

            frameinfo = Ref(CodecLz4.LZ4F_frameInfo_t())

            CodecLz4.LZ4F_createDecompressionContext(dctx, version)

            buffer[1:CodecLz4.LZ4F_HEADER_SIZE_MAX] .= 0x10
            @test_throws CodecLz4.LZ4Exception CodecLz4.LZ4F_getFrameInfo(dctx[], frameinfo, buffer, srcsize)

            offset = srcsize[]
            srcsize[] = origsize - offset

            @test_throws CodecLz4.LZ4Exception CodecLz4.LZ4F_decompress(dctx[], decbuffer, dstsize, pointer(buffer) + offset, srcsize, C_NULL)

            result = CodecLz4.LZ4F_freeDecompressionContext(dctx[])
            @test !CodecLz4.LZ4F_isError(result)
        end
    end

    @testset "Compress" begin
        ctx = Ref{Ptr{CodecLz4.LZ4F_cctx}}(C_NULL)
        err = CodecLz4.LZ4F_isError(CodecLz4.LZ4F_createCompressionContext(ctx, version))
        @test !err

        prefs = Ptr{CodecLz4.LZ4F_preferences_t}(C_NULL)

        bound = CodecLz4.LZ4F_compressBound(test_size, prefs)
        @test bound > 0

        bufsize = bound + CodecLz4.LZ4F_HEADER_SIZE_MAX
        buffer = Vector{UInt8}(undef, ceil(Int, bound / 8))

        @test_nowarn result = CodecLz4.LZ4F_compressBegin(ctx[], buffer, bufsize, prefs)

        offset = result
        @test_nowarn result = CodecLz4.LZ4F_compressUpdate(ctx[], pointer(buffer) + offset, bufsize - offset, pointer(test_in), test_size, C_NULL)

        offset += result
        @test_nowarn result = CodecLz4.LZ4F_flush(ctx[], pointer(buffer)+offset, bufsize - offset, C_NULL)

        offset += result
        @test_nowarn result = CodecLz4.LZ4F_compressEnd(ctx[], pointer(buffer)+offset, bufsize - offset, C_NULL)
        @test result > 0

        offset += result

        result = CodecLz4.LZ4F_freeCompressionContext(ctx[])
        @test !CodecLz4.LZ4F_isError(result)

        test_decompress(offset, buffer)
        test_invalid_decompress(offset, buffer)
    end

    @testset "CompressUninitialized" begin
        ctx = Ref{Ptr{CodecLz4.LZ4F_cctx}}(C_NULL)

        prefs = Ptr{CodecLz4.LZ4F_preferences_t}(C_NULL)

        bufsize = test_size
        buffer = Vector{UInt8}(undef, test_size)

        @test_throws CodecLz4.LZ4Exception CodecLz4.LZ4F_compressBegin(ctx[], buffer, bufsize, prefs)
        @test_throws CodecLz4.LZ4Exception CodecLz4.LZ4F_compressUpdate(ctx[], pointer(buffer), bufsize, pointer(test_in), test_size, C_NULL)
        @test_throws CodecLz4.LZ4Exception CodecLz4.LZ4F_flush(ctx[], pointer(buffer), bufsize, C_NULL)
        @test_throws CodecLz4.LZ4Exception CodecLz4.LZ4F_compressEnd(ctx[], pointer(buffer), bufsize, C_NULL)
    end

    @testset "CompressInvalid" begin
        ctx = Ref{Ptr{CodecLz4.LZ4F_cctx}}(C_NULL)
        CodecLz4.LZ4F_createCompressionContext(ctx, version)

        prefs = Ptr{CodecLz4.LZ4F_preferences_t}(C_NULL)

        bound = CodecLz4.LZ4F_compressBound(test_size, prefs)
        @test bound > 0

        bufsize = bound + CodecLz4.LZ4F_HEADER_SIZE_MAX
        buffer = Vector{UInt8}(undef, ceil(Int, bound / 8))

        @test_throws CodecLz4.LZ4Exception CodecLz4.LZ4F_compressBegin(ctx[], buffer, UInt(2), prefs)
        @test_throws CodecLz4.LZ4Exception CodecLz4.LZ4F_compressUpdate(ctx[], pointer(buffer), bufsize, pointer(test_in), test_size, C_NULL)

        result = CodecLz4.LZ4F_freeCompressionContext(ctx[])
        @test !CodecLz4.LZ4F_isError(result)


        ctx = Ref{Ptr{CodecLz4.LZ4F_cctx}}(C_NULL)
        CodecLz4.LZ4F_createCompressionContext(ctx, version)

        @test_nowarn result = CodecLz4.LZ4F_compressBegin(ctx[], buffer, bufsize, prefs)

        offset = result
        @test_nowarn result = CodecLz4.LZ4F_compressUpdate(ctx[], pointer(buffer) + offset, bufsize - offset, pointer(test_in), test_size, C_NULL)

        @test_throws CodecLz4.LZ4Exception CodecLz4.LZ4F_flush(ctx[], pointer(buffer), UInt(2), C_NULL)
        @test_throws CodecLz4.LZ4Exception CodecLz4.LZ4F_compressEnd(ctx[], pointer(buffer), UInt(2), C_NULL)

        result = CodecLz4.LZ4F_freeCompressionContext(ctx[])
        @test !CodecLz4.LZ4F_isError(result)
    end

    @testset "DecompressUninitialized" begin
        dctx = Ref{Ptr{CodecLz4.LZ4F_dctx}}(C_NULL)
        srcsize = Ref{Csize_t}(test_size)
        dstsize =  Ref{Csize_t}(8*1280)
        decbuffer = Vector{UInt8}(undef, 1280)

        frameinfo = Ref(CodecLz4.LZ4F_frameInfo_t())
        @test_throws CodecLz4.LZ4Exception CodecLz4.LZ4F_getFrameInfo(dctx[], frameinfo, pointer(test_in), srcsize)
        @test_throws CodecLz4.LZ4Exception CodecLz4.LZ4F_decompress(dctx[], decbuffer, dstsize, pointer(test_in), srcsize, C_NULL)
    end

    @testset "Preferences" begin
        ctx = Ref{Ptr{CodecLz4.LZ4F_cctx}}(C_NULL)
        err = CodecLz4.LZ4F_isError(CodecLz4.LZ4F_createCompressionContext(ctx, version))
        @test !err
        opts = Ref(CodecLz4.LZ4F_compressOptions_t(1, (0, 0, 0)))
        prefs = Ref(CodecLz4.LZ4F_preferences_t(CodecLz4.LZ4F_frameInfo_t(), 20, 0, (0, 0, 0, 0)))

        bound = CodecLz4.LZ4F_compressBound(test_size, prefs)
        @test bound > 0

        bufsize = bound + CodecLz4.LZ4F_HEADER_SIZE_MAX
        buffer = Vector{UInt8}(undef, ceil(Int, bound / 8))

        @test_nowarn result = CodecLz4.LZ4F_compressBegin(ctx[], buffer, bufsize, prefs)

        offset = result
        @test_nowarn result = CodecLz4.LZ4F_compressUpdate(ctx[], pointer(buffer) + offset, bufsize - offset, pointer(test_in), test_size, opts)

        offset += result
        @test_nowarn result = CodecLz4.LZ4F_flush(ctx[], pointer(buffer) + offset, bufsize - offset, opts)

        offset += result
        @test_nowarn result = CodecLz4.LZ4F_compressEnd(ctx[], pointer(buffer) + offset, bufsize - offset, opts)
        @test result > 0

        offset += result

        result = CodecLz4.LZ4F_freeCompressionContext(ctx[])
        @test !CodecLz4.LZ4F_isError(result)

        test_decompress(offset, buffer)
    end

end
