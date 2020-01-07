@testset "lz4" begin

    test_in = """
        Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor
        incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud
        exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat
        """
    test_size = convert(Int32, length(test_in))
    bound = CodecLz4.LZ4_compressBound(test_size)
    bufsize = bound
    half_bufsize = floor(Cint, bufsize/2)

    @testset "bounds" begin
        bound = CodecLz4.LZ4_compressBound(test_size)
        @test bound > 0

        bound = CodecLz4.LZ4_compressBound(CodecLz4.LZ4_MAX_INPUT_SIZE)
        @test bound > 0

        bound = CodecLz4.LZ4_compressBound(CodecLz4.LZ4_MAX_INPUT_SIZE + 1)
        @test bound == 0
    end

    @testset "fast" begin
        buffer = Vector{UInt8}(undef, bufsize)
        dec_buffer = Vector{UInt8}(undef, test_size)
        result = CodecLz4.LZ4_compress_fast(test_in, buffer, test_size, bufsize, 12)

        result = CodecLz4.LZ4_decompress_safe(buffer, dec_buffer, result, test_size)
        @test unsafe_string(pointer(dec_buffer), result) == test_in

        @test_throws CodecLz4.LZ4Exception CodecLz4.LZ4_compress_fast(test_in, buffer, test_size, half_bufsize, 12)
    end

    @testset "destSize" begin
        buffer = Vector{UInt8}(undef, bufsize)
        dec_buffer = Vector{UInt8}(undef, test_size)
        sz = Ref{Int32}(test_size)

        compressed = CodecLz4.LZ4_compress_destSize(test_in, buffer, sz, half_bufsize)
        @test compressed == half_bufsize
        @test sz[] > 0

        result = CodecLz4.LZ4_decompress_safe(buffer, dec_buffer, compressed, sz[])
        @test result == sz[]
        @test unsafe_string(pointer(dec_buffer), result) == test_in[1:sz[]]
    end

    @testset "streams" begin
        buffer = Vector{UInt8}(undef, bufsize)
        dec_buffer = Vector{UInt8}(undef, test_size)
        comp_str = CodecLz4.LZ4_createStream()
        dec_str = CodecLz4.LZ4_createStreamDecode()
        try
            @test CodecLz4.LZ4_resetStream(comp_str) === nothing
            @test CodecLz4.LZ4_setStreamDecode(dec_str, Ptr{UInt8}(C_NULL), Cint(0)) == 1

            result = CodecLz4.LZ4_compress_fast_continue(comp_str, test_in, buffer, test_size, bufsize, 12)
            @test result > 0
            result = CodecLz4.LZ4_decompress_safe_continue(dec_str, buffer, dec_buffer, result, test_size)

            @test result == test_size
            @test unsafe_string(pointer(dec_buffer), result) == test_in
        finally
            @test CodecLz4.LZ4_freeStream(comp_str) == 0
            @test CodecLz4.LZ4_freeStreamDecode(dec_str) == 0
        end
    end

    @testset "uninitialized" begin
        buffer = Vector{UInt8}(undef, bufsize)
        dec_buffer = Vector{UInt8}(undef, test_size)
        stream = Ref{Ptr{CodecLz4.LZ4_stream_t}}(C_NULL)

        @test_throws CodecLz4.LZ4Exception CodecLz4.LZ4_resetStream(stream[])
        @test_throws CodecLz4.LZ4Exception CodecLz4.LZ4_compress_fast_continue(stream[], test_in, buffer, test_size, bufsize)
        @test CodecLz4.LZ4_freeStream(stream[]) == 0

        stream = Ref{Ptr{CodecLz4.LZ4_streamDecode_t}}(C_NULL)

        @test_throws CodecLz4.LZ4Exception CodecLz4.LZ4_setStreamDecode(stream[])
        @test_throws CodecLz4.LZ4Exception CodecLz4.LZ4_decompress_safe_continue(stream[], test_in, buffer, test_size, bufsize)
        @test CodecLz4.LZ4_freeStreamDecode(stream[]) == 0
    end

end
