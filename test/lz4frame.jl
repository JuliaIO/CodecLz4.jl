@testset "lz4framed" begin
     testIn = "Far out in the uncharted backwaters of the unfashionable end of the west-
 ern  spiral  arm  of  the  Galaxy  lies  a  small  unregarded  yellow  sun."
	test_size = convert(UInt, length(testIn))
	version = LZ4F_getVersion()

	@testset "Errors" begin
		ERROR_GENERIC = (UInt)(18446744073709551615)
		no_error = (UInt)(0)

		@test !LZ4F_isError(no_error)
		@test LZ4F_getErrorName(no_error) == "Unspecified error code"
		
		@test LZ4F_isError(ERROR_GENERIC)
		@test LZ4F_getErrorName(ERROR_GENERIC) == "ERROR_GENERIC"
	end

	@testset "CompressionCtx" begin
		ctx = Ref{Ptr{LZ4F_cctx}}(C_NULL)
		
		@test_nowarn err = LZ4F_createCompressionContext(ctx, version)
		@test err == 0

		@test_nowarn check_context_initialized(ctx[])

		err = LZ4F_freeCompressionContext(ctx[])
		@test err == 0
		@test !LZ4F_isError(err)

		ctx = Ptr{LZ4F_cctx}(C_NULL)
		@test_throws ErrorException check_context_initialized(ctx)
	end


	@testset "DecompressionCtx" begin
		dctx = Ref{Ptr{LZ4F_dctx}}(C_NULL)
		
		@test_nowarn err = LZ4F_createDecompressionContext(dctx, version)
		@test err == 0
		
		@test_nowarn check_context_initialized(dctx[])

		@test_nowarn LZ4F_resetDecompressionContext(dctx[])

		err = LZ4F_freeDecompressionContext(dctx[])
		@test err == 0

		dctx = Ptr{LZ4F_dctx}(C_NULL)
		@test_throws ErrorException check_context_initialized(dctx)
		@test_throws ErrorException LZ4F_resetDecompressionContext(dctx)

	end

	function test_decompress(origsize, buffer)
		@testset "Decompress" begin
			dctx = Ref{Ptr{LZ4F_dctx}}(C_NULL)
			srcsize = Ref{Csize_t}(origsize)
			dstsize =  Ref{Csize_t}(8*1280)
			decbuffer = Vector{UInt8}(1280)

			frameinfo = Ref(LZ4F_frameInfo_t())

			@test_nowarn err = LZ4F_createDecompressionContext(dctx, version)
			
			@test_nowarn result = LZ4F_getFrameInfo(dctx[], frameinfo, buffer, srcsize)
			@test srcsize[] > 0

			offset = srcsize[]
			srcsize[]=origsize-offset

			@test_nowarn result = LZ4F_decompress(dctx[], decbuffer, dstsize, pointer(buffer)+offset, srcsize, C_NULL)
			@test srcsize[] > 0
			
			@test testIn == unsafe_string(pointer(decbuffer))

			result = LZ4F_freeDecompressionContext(dctx[])
			@test !LZ4F_isError(result)	
		end

	end

	function test_invalid_decompress(origsize, buffer)
		@testset "DecompressInvalid" begin

			dctx = Ref{Ptr{LZ4F_dctx}}(C_NULL)
			srcsize = Ref{Csize_t}(origsize)
			dstsize =  Ref{Csize_t}(1280)
			decbuffer = Vector{UInt8}(1280)

			frameinfo = Ref(LZ4F_frameInfo_t())
			
			LZ4F_createDecompressionContext(dctx, version)
			
			buffer[1:LZ4F_HEADER_SIZE_MAX] =0x10
			@test_throws ErrorException LZ4F_getFrameInfo(dctx[], frameinfo, buffer, srcsize)

			offset = srcsize[]
			srcsize[]=origsize-offset

			@test_throws ErrorException LZ4F_decompress(dctx[], decbuffer, dstsize, pointer(buffer)+offset, srcsize, C_NULL)

			result = LZ4F_freeDecompressionContext(dctx[])
			@test !LZ4F_isError(result)
		end
	end

	@testset "CompressFrame" begin
		maxCompression = LZ4F_compressionLevel_max()
	    @test  maxCompression == 12
	    frameprefs = Ref(LZ4F_preferences_t(LZ4F_frameInfo_t(),maxCompression,0,(0,0,0,0)))
	    
	    result = LZ4F_compressFrameBound(test_size, frameprefs)
	    @test result > 0

	    result += LZ4F_HEADER_SIZE_MAX

	    compbuffer = Vector{UInt8}(result)
		result = LZ4F_compressFrame(compbuffer, result, pointer(testIn), test_size, frameprefs) 
		@test !LZ4F_isError(result)

		test_decompress(result, compbuffer)
		
	end

	@testset "CompressFrameInvalid" begin
		frameprefs = Ref(LZ4F_preferences_t(LZ4F_frameInfo_t()))

	    compbuffer = Vector{UInt8}(1280)
		@test_throws ErrorException LZ4F_compressFrame(compbuffer, (UInt)(2), pointer(testIn), test_size, frameprefs) 
		
	end

	@testset "Compress" begin
		ctx = Ref{Ptr{LZ4F_cctx}}(C_NULL)
		err = LZ4F_isError(LZ4F_createCompressionContext(ctx, version))
		@test !err

		prefs = Ptr{LZ4F_preferences_t}(C_NULL)
		
		bound = LZ4F_compressBound(test_size, prefs)
		@test bound > 0

		bufsize = bound + LZ4F_HEADER_SIZE_MAX
		buffer = Vector{UInt8}(ceil(Int, bound/8))

		@test_nowarn result = LZ4F_compressBegin(ctx[], buffer, bufsize, prefs)
		
		offset = result
		@test_nowarn result = LZ4F_compressUpdate(ctx[], pointer(buffer) + offset, bufsize - offset, pointer(testIn), test_size, C_NULL)
		 
		offset += result
		@test_nowarn result = LZ4F_flush(ctx[], pointer(buffer)+offset, bufsize - offset, C_NULL)

		offset += result
		@test_nowarn result = LZ4F_compressEnd(ctx[], pointer(buffer)+offset, bufsize - offset, C_NULL)
		@test result>0
		
		offset += result
		
		result = LZ4F_freeCompressionContext(ctx[])
		@test !LZ4F_isError(result)
		
		test_decompress(offset, buffer)
		test_invalid_decompress(offset, buffer)
	end

	@testset "CompressUninitialized" begin
	    ctx = Ref{Ptr{LZ4F_cctx}}(C_NULL)
		
		prefs = Ptr{LZ4F_preferences_t}(C_NULL)

		bufsize = test_size
		buffer = Vector{UInt8}(test_size)

		@test_throws ErrorException LZ4F_compressBegin(ctx[], buffer, bufsize, prefs)
		@test_throws ErrorException LZ4F_compressUpdate(ctx[], pointer(buffer), bufsize, pointer(testIn), test_size, C_NULL) 
		@test_throws ErrorException LZ4F_flush(ctx[], pointer(buffer), bufsize, C_NULL)
		@test_throws ErrorException LZ4F_compressEnd(ctx[], pointer(buffer), bufsize, C_NULL)
	end

	@testset "CompressInvalid" begin
		ctx = Ref{Ptr{LZ4F_cctx}}(C_NULL)
		LZ4F_createCompressionContext(ctx, version)

		prefs = Ptr{LZ4F_preferences_t}(C_NULL)
		
		bound = LZ4F_compressBound(test_size, prefs)
		@test bound > 0

		bufsize = bound + LZ4F_HEADER_SIZE_MAX
		buffer = Vector{UInt8}(ceil(Int, bound/8))

		@test_throws ErrorException LZ4F_compressBegin(ctx[], buffer, (UInt)(2), prefs)
		@test_throws ErrorException LZ4F_compressUpdate(ctx[], pointer(buffer), bufsize, pointer(testIn), test_size, C_NULL)
		
		result = LZ4F_freeCompressionContext(ctx[])
		@test !LZ4F_isError(result)


		ctx = Ref{Ptr{LZ4F_cctx}}(C_NULL)
		LZ4F_createCompressionContext(ctx, version)

		@test_nowarn result = LZ4F_compressBegin(ctx[], buffer, bufsize, prefs)
		
		offset = result
		@test_nowarn result = LZ4F_compressUpdate(ctx[], pointer(buffer) + offset, bufsize - offset, pointer(testIn), test_size, C_NULL)
		 
		@test_throws ErrorException LZ4F_flush(ctx[], pointer(buffer), (UInt)(2), C_NULL)
		@test_throws ErrorException LZ4F_compressEnd(ctx[], pointer(buffer), (UInt)(2), C_NULL)
		
		result = LZ4F_freeCompressionContext(ctx[])
		@test !LZ4F_isError(result)
	end

	@testset "DecompressUninitialized" begin
	    dctx = Ref{Ptr{LZ4F_dctx}}(C_NULL)
		srcsize = Ref{Csize_t}(test_size)
		dstsize =  Ref{Csize_t}(8*1280)
		decbuffer = Vector{UInt8}(1280)

		frameinfo = Ref(LZ4F_frameInfo_t())
		@test_throws ErrorException LZ4F_getFrameInfo(dctx[], frameinfo, pointer(testIn), srcsize)
		@test_throws ErrorException LZ4F_decompress(dctx[], decbuffer, dstsize, pointer(testIn), srcsize, C_NULL)
	end
	
	@testset "Preferences" begin
		ctx = Ref{Ptr{LZ4F_cctx}}(C_NULL)
		err = LZ4F_isError(LZ4F_createCompressionContext(ctx, version))
		@test !err
	  	opts = Ref(LZ4F_compressOptions_t(1,(0,0,0)))
	    prefs = Ref(LZ4F_preferences_t(LZ4F_frameInfo_t(),LZ4F_compressionLevel_max(),0,(0,0,0,0)))
	    
		bound = LZ4F_compressBound(test_size, prefs)
		@test bound > 0

		bufsize = bound + LZ4F_HEADER_SIZE_MAX
		buffer = Vector{UInt8}(ceil(Int, bound/8))

		@test_nowarn result = LZ4F_compressBegin(ctx[], buffer, bufsize, prefs)
		
		offset = result
		@test_nowarn result = LZ4F_compressUpdate(ctx[], pointer(buffer) + offset, bufsize - offset, pointer(testIn), test_size, opts)

		offset += result
		@test_nowarn result = LZ4F_flush(ctx[], pointer(buffer)+offset, bufsize - offset, opts)

		offset += result
		@test_nowarn result = LZ4F_compressEnd(ctx[], pointer(buffer)+offset, bufsize - offset, opts)
		@test result>0
		
		offset += result
		
		result = LZ4F_freeCompressionContext(ctx[])
		@test !LZ4F_isError(result)
		
		test_decompress(offset, buffer)
	end

end


