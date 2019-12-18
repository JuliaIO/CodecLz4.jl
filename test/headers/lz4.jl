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
    buffer = Vector{UInt8}(undef, bufsize)
    dec_buffer = Vector{UInt8}(undef, test_size)


    @testset "bounds" begin
        bound = CodecLz4.LZ4_compressBound(test_size)
        @test bound > 0

        bound = CodecLz4.LZ4_compressBound(CodecLz4.LZ4_MAX_INPUT_SIZE)
        @test bound > 0

        bound = CodecLz4.LZ4_compressBound(CodecLz4.LZ4_MAX_INPUT_SIZE + 1)
        @test bound == 0
    end

    @testset "fast" begin
        result = CodecLz4.LZ4_compress_fast(pointer(test_in), pointer(buffer), test_size, bufsize, 12)

        result = CodecLz4.LZ4_decompress_safe(pointer(buffer), pointer(dec_buffer), result, test_size)
        @test unsafe_string(pointer(dec_buffer), test_size) == test_in

        @test_throws CodecLz4.LZ4Exception CodecLz4.LZ4_compress_fast(pointer(test_in), pointer(buffer), test_size, half_bufsize, 12)
    end

    @testset "destSize" begin
        sz = Ref{Int32}(test_size)

        compressed = CodecLz4.LZ4_compress_destSize(pointer(test_in), pointer(buffer), sz, half_bufsize)
        @test compressed == half_bufsize
        @test sz[] > 0

        result = CodecLz4.LZ4_decompress_safe(pointer(buffer), pointer(dec_buffer), compressed, sz[])
        @test result == sz[]
        @test unsafe_string(pointer(dec_buffer), result) == test_in[1:sz[]]
    end

    @testset "streams" begin
        comp_str = CodecLz4.LZ4_createStream()
        dec_str = CodecLz4.LZ4_createStreamDecode()
        try
            @test CodecLz4.LZ4_resetStream(comp_str) === nothing
            @test CodecLz4.LZ4_setStreamDecode(dec_str, Ptr{UInt8}(C_NULL), Cint(0)) == 1

            result = CodecLz4.LZ4_compress_fast_continue(comp_str, pointer(test_in), pointer(buffer), test_size, bufsize, 12)
            @test result > 0
            result = CodecLz4.LZ4_decompress_safe_continue(dec_str, pointer(buffer), pointer(dec_buffer), result, test_size)

            @test result == test_size
            @test unsafe_string(pointer(dec_buffer), result) == test_in
        finally
            @test CodecLz4.LZ4_freeStream(comp_str) == 0
            @test CodecLz4.LZ4_freeStreamDecode(dec_str) == 0
        end
    end
end
