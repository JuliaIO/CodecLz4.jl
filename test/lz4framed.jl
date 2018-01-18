
@testset "lz4framed" begin
     testIn = "Far out in the uncharted backwaters of the unfashionable end of the west-
 ern  spiral  arm  of  the  Galaxy  lies  a  small  unregarded  yellow  sun."
	
	version = LZ4F_getVersion()
	const LZ4F_FOOTER_SIZE = 8
	bufsize = convert(UInt, (8*1280))
	buffer = Vector{UInt8}(ceil(Int, bufsize/8))
	offset = 0

	@testset "Errors" begin
		ERROR_dstMaxSize_tooSmall = (UInt)(18446744073709551605)
		NoError = (UInt)(0)

		err = LZ4F_isError(NoError)
		@test err == 0
		@test unsafe_string(LZ4F_getErrorName(NoError)) == "Unspecified error code"

		err = LZ4F_isError(ERROR_dstMaxSize_tooSmall)
		@test err == 0x1
		@test unsafe_string(LZ4F_getErrorName(ERROR_dstMaxSize_tooSmall)) == "ERROR_dstMaxSize_tooSmall"
	end

	@testset "CompressionCtx" begin
		ctx = Ref{Ptr{LZ4F_cctx}}(C_NULL)
		
		err = LZ4F_createCompressionContext(ctx, version)
		@test err == 0
		err = LZ4F_isError(err)
		@test err == 0
		err = LZ4F_freeCompressionContext(ctx[])
		@test err == 0
	end

	@testset "Compress" begin
		ctx = Ref{Ptr{LZ4F_cctx}}(C_NULL)
		err = LZ4F_isError(LZ4F_createCompressionContext(ctx, version))
		@test err == 0
		prefs = Ptr{LZ4F_preferences_t}(C_NULL)
		
		bound = LZ4F_compressBound(bufsize, prefs)
		@test bound>0

		bufsize = bound + LZ4F_HEADER_SIZE_MAX+LZ4F_FOOTER_SIZE
		buffer = Vector{UInt8}(ceil(Int, bound/8))

		result = LZ4F_compressBegin(ctx[], buffer, bufsize, prefs)
		err = LZ4F_isError(result)
		@test err == 0

		offset = result
		testSize = convert(UInt, sizeof(testIn))
		result = LZ4F_compressUpdate(ctx[], pointer(buffer) + offset, bufsize - offset, pointer(testIn), testSize, C_NULL)
		err = LZ4F_isError(result)
		@test err == 0

		offset += result
		result = LZ4F_compressEnd(ctx[], pointer(buffer)+offset, bufsize - offset, C_NULL)
		err = LZ4F_isError(result)
		
		@test result>0
		@test err == 0
		offset += result
		
		result = LZ4F_freeCompressionContext(ctx[])
		err = LZ4F_isError(result)
		@test err == 0
	end
	
	@testset "DecompressionCtx" begin
		dctx = Ref{Ptr{LZ4F_dctx}}(C_NULL)
		
		err = LZ4F_createDecompressionContext(dctx, version)
		@test err == 0
		err = LZ4F_isError(err)
		@test err == 0
		err = LZ4F_freeDecompressionContext(dctx[])
		@test err == 0
	end

	@testset "Decompress" begin
		dctx = Ref{Ptr{LZ4F_dctx}}(C_NULL)
		srcsize = Ref{Csize_t}(offset)
		dstsize =  Ref{Csize_t}(8*1280)
		decbuffer = Vector{UInt8}(1280)

		a = (UInt)(0)
		frameinfo = LZ4F_frameInfo_t(a,a,a,a,a,a,a)


		err = LZ4F_createDecompressionContext(dctx, version)
		@test err == 0
		err = LZ4F_isError(err)
		@test err == 0
		
		result = LZ4F_getFrameInfo(dctx[], frameinfo, buffer, srcsize)
		
		err = LZ4F_isError(result)
		@test err == 0
		@test srcsize[] > 0

		bufsize = offset-srcsize[]
		offset = srcsize[]
		srcsize[]=bufsize

		result = LZ4F_decompress(dctx[], decbuffer, dstsize, pointer(buffer)+offset, srcsize, C_NULL)
		err = LZ4F_isError(result)
		@test err == 0
		@test srcsize[] > 0
		
		@test testIn == unsafe_string(pointer(decbuffer))

		result = LZ4F_freeDecompressionContext(dctx[])
		err = LZ4F_isError(result)
		@test err == 0
		
	end


end