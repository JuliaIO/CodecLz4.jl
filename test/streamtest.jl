const LZ4F_FOOTER_SIZE_MAX = 4
const BUF_SIZE = 8*2048
function compress_stream(instream::IO, outstream::IO)
	
	ctx = Ref{Ptr{LZ4F_cctx}}(C_NULL)
	err = LZ4F_isError(LZ4F_createCompressionContext(ctx, version))
	@test err == 0

	prefs = Ptr{LZ4F_preferences_t}(C_NULL)
	bound = LZ4F_compressBound(BUF_SIZE, prefs)
	@test bound > 0
	
	bufsize = bound + LZ4F_HEADER_SIZE_MAX + LZ4F_FOOTER_SIZE_MAX
	outbuffer = Vector{UInt8}(bufsize)
	inbuffer = Vector{UInt8}(BUF_SIZE)

	result = LZ4F_compressBegin(ctx[], outbuffer, bufsize, prefs)
	@test !LZ4F_isError(result)

	offset = result
	pos = 0
	readlen = eof(instream)? 0 : readbytes!(instream, inbuffer, BUF_SIZE)

	while readlen>0 
		result = LZ4F_compressUpdate(ctx[], pointer(outbuffer) + offset, bufsize - offset, pointer(inbuffer), testSize, C_NULL)
		@test !LZ4F_isError(result)

		offset += result
		if bufsize-offset<bound
			unsafe_write(outstream, pointer(buf), offset)
			offset = 0
		end
		
		readlen = eof(instream)? 0 : readbytes!(instream, inbuffer, BUF_SIZE)
	end

	result = LZ4F_compressEnd(ctx[], pointer(outbuffer)+offset, bufsize - offset, C_NULL)
	@test !LZ4F_isError(result)
	@test result>0
	
	offset += result
	unsafe_write(outstream, pointer(buf), offset)

	result = LZ4F_freeCompressionContext(ctx[])
	@test !LZ4F_isError(result)

	#test_decompress(offset, outbuffer)
end


function decompress_stream(instream::IO, outstream::IO)

	dctx = Ref{Ptr{LZ4F_dctx}}(C_NULL)
	srcsize = Ref{Csize_t}(origsize)
	dstsize =  Ref{Csize_t}(8*1280)
	decbuffer = Vector{UInt8}(1280)

	frameinfo = LZ4F_frameInfo_t()

	err = LZ4F_createDecompressionContext(dctx, version)
	if LZ4F_isError(err)
		error("Failed to create context: " * LZ4F_getErrorName(headerSize))
	end
	
	result = LZ4F_getFrameInfo(dctx[], frameinfo, buffer, srcsize)
	@test !LZ4F_isError(result)
	@test srcsize[] > 0

	offset = srcsize[]
	srcsize[]=origsize-offset

		result = LZ4F_decompress(dctx[], decbuffer, dstsize, pointer(buffer)+offset, srcsize, C_NULL)
		@test !LZ4F_isError(result)
		@test srcsize[] > 0
	
		#writeout test testIn == unsafe_string(pointer(decbuffer))

	result = LZ4F_freeDecompressionContext(dctx[])
	@test !LZ4F_isError(result)
end


