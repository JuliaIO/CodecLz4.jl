@testset "lz4framed" begin
     testIn = "Far out in the uncharted backwaters of the unfashionable end of the west-
 ern  spiral  arm  of  the  Galaxy  lies  a  small  unregarded  yellow  sun."
	testSize = convert(UInt, length(testIn))
	version = LZ4F_getVersion()

	@testset "Errors" begin
		ERROR_GENERIC = (UInt)(18446744073709551615)
		NoError = (UInt)(0)

		@test !LZ4F_isError(NoError)
		@test LZ4F_getErrorName(NoError) == "Unspecified error code"
		
		@test LZ4F_isError(ERROR_GENERIC)
		@test LZ4F_getErrorName(ERROR_GENERIC) == "ERROR_GENERIC"
	end

	@testset "CompressionCtx" begin
		ctx = Ref{Ptr{LZ4F_cctx}}(C_NULL)
		
		@test_nowarn err = LZ4F_createCompressionContext(ctx, version)
		@test err == 0

		err = LZ4F_freeCompressionContext(ctx[])
		@test err == 0
		@test !LZ4F_isError(err)
	end


	@testset "DecompressionCtx" begin
		dctx = Ref{Ptr{LZ4F_dctx}}(C_NULL)
		
		@test_nowarn err = LZ4F_createDecompressionContext(dctx, version)
		@test err == 0
		
		@test_nowarn LZ4F_resetDecompressionContext(dctx[])

		err = LZ4F_freeDecompressionContext(dctx[])
		@test err == 0

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

	@testset "CompressFrame" begin
		maxCompression = LZ4F_compressionLevel_max()
	    @test  maxCompression == 12
	    frameprefs = Ref(LZ4F_preferences_t(LZ4F_frameInfo_t(),maxCompression,0,(0,0,0,0)))
	    
	    result = LZ4F_compressFrameBound(testSize, frameprefs)
	    @test result > 0

	    result += LZ4F_HEADER_SIZE_MAX

	    compbuffer = Vector{UInt8}(result)
		result = LZ4F_compressFrame(compbuffer, result, pointer(testIn), testSize, frameprefs) 
		@test !LZ4F_isError(result)

		test_decompress(result, compbuffer)
		
	end

	@testset "Compress" begin
		ctx = Ref{Ptr{LZ4F_cctx}}(C_NULL)
		err = LZ4F_isError(LZ4F_createCompressionContext(ctx, version))
		@test !err

		prefs = Ptr{LZ4F_preferences_t}(C_NULL)
		
		bound = LZ4F_compressBound(testSize, prefs)
		@test bound > 0

		bufsize = bound + LZ4F_HEADER_SIZE_MAX
		buffer = Vector{UInt8}(ceil(Int, bound/8))

		@test_nowarn result = LZ4F_compressBegin(ctx[], buffer, bufsize, prefs)
		
		offset = result
		@test_nowarn result = LZ4F_compressUpdate(ctx[], pointer(buffer) + offset, bufsize - offset, pointer(testIn), testSize, C_NULL)
		 

		offset += result
		@test_nowarn result = LZ4F_flush(ctx[], pointer(buffer)+offset, bufsize - offset, C_NULL)
		

		offset += result
		@test_nowarn result = LZ4F_compressEnd(ctx[], pointer(buffer)+offset, bufsize - offset, C_NULL)
		@test result>0
		
		offset += result
		
		result = LZ4F_freeCompressionContext(ctx[])
		@test !LZ4F_isError(result)
		
		test_decompress(offset, buffer)
	end
	
	@testset "Preferences" begin
		ctx = Ref{Ptr{LZ4F_cctx}}(C_NULL)
		err = LZ4F_isError(LZ4F_createCompressionContext(ctx, version))
		@test !err
	  	opts = Ref(LZ4F_compressOptions_t(1,(0,0,0)))
	    prefs = Ref(LZ4F_preferences_t(LZ4F_frameInfo_t(),LZ4F_compressionLevel_max(),0,(0,0,0,0)))
	    
		bound = LZ4F_compressBound(testSize, prefs)
		@test bound > 0

		bufsize = bound + LZ4F_HEADER_SIZE_MAX
		buffer = Vector{UInt8}(ceil(Int, bound/8))

		@test_nowarn result = LZ4F_compressBegin(ctx[], buffer, bufsize, prefs)
		
		offset = result
		@test_nowarn result = LZ4F_compressUpdate(ctx[], pointer(buffer) + offset, bufsize - offset, pointer(testIn), testSize, opts)

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


