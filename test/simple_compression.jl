test_in = b"""
    Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor
    incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud
    exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat
    """

@testset "simple_compression" begin
    comp = lz4_compress(test_in, 5)
    @test comp != test_in

    decomp = lz4_decompress(comp)
    @test decomp == test_in

    comp = lz4_hc_compress(test_in, 12)
    @test comp != test_in
    decomp = lz4_decompress(comp)
    @test decomp == test_in

    huge_vector = rand(UInt8, CodecLz4.LZ4_MAX_INPUT_SIZE + 1)
    @test_throws CodecLz4.LZ4Exception lz4_hc_compress(huge_vector)
    @test_throws CodecLz4.LZ4Exception lz4_compress(huge_vector)
    @test_throws CodecLz4.LZ4Exception lz4_decompress(comp, floor(Int, length(test_in)/2))
    @test_throws CodecLz4.LZ4Exception lz4_decompress(test_in)
end
