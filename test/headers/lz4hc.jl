@testset "lz4hc" begin
    test_in = """
        Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor
        incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud
        exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat
        """
    test_size = convert(Cint, length(test_in))
    bound = CodecLz4.LZ4_compressBound(test_size)
    bufsize = bound
    half_bufsize = floor(Cint, bufsize/2)
    buffer = Vector{UInt8}(undef, bufsize)
    dec_buffer = Vector{UInt8}(undef, test_size)

    @testset "compress" begin
        result = CodecLz4.LZ4_compress_HC(pointer(test_in), pointer(buffer), test_size, bufsize, 13)

        result = CodecLz4.LZ4_decompress_safe(pointer(buffer), pointer(dec_buffer), result, test_size)
        @test unsafe_string(pointer(dec_buffer), test_size) == test_in

        @test_throws CodecLz4.LZ4Exception CodecLz4.LZ4_compress_HC(pointer(test_in), pointer(buffer), test_size, half_bufsize, 12)
    end

    @testset "streams" begin
        comp_str = CodecLz4.LZ4_createStreamHC()
        try
            @test CodecLz4.LZ4_resetStreamHC(comp_str, 1) === nothing

            result = CodecLz4.LZ4_compress_HC_continue(comp_str, pointer(test_in), pointer(buffer), test_size, bufsize)
            @test result > 0
            result = CodecLz4.LZ4_decompress_safe(pointer(buffer), pointer(dec_buffer), result, test_size)

            @test result == test_size
            @test unsafe_string(pointer(dec_buffer), result) == test_in
        finally
            @test CodecLz4.LZ4_freeStreamHC(comp_str) == 0
        end
    end

    @testset "errors" begin
        stream = Ref{Ptr{CodecLz4.LZ4_streamHC_t}}(C_NULL)

        @test_throws CodecLz4.LZ4Exception CodecLz4.LZ4_resetStreamHC(stream[])
        @test_throws CodecLz4.LZ4Exception CodecLz4.LZ4_compress_HC_continue(stream[], pointer(test_in), pointer(buffer), test_size, bufsize)
        @test CodecLz4.LZ4_freeStreamHC(stream[]) == 0
    end
end
