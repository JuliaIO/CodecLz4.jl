@testset "hc_compression" begin
    text = b"""
    Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aenean sollicitudin
    mauris non nisi consectetur, a dapibus urna pretium. Vestibulum non posuere
    erat. Donec luctus a turpis eget aliquet. Cras tristique iaculis ex, eu
    malesuada sem interdum sed. Vestibulum ante ipsum primis in faucibus orci luctus
    et ultrices posuere cubilia Curae; Etiam volutpat, risus nec gravida ultricies,
    erat ex bibendum ipsum, sed varius ipsum ipsum vitae dui.
    """

    @testset "Transcoding" begin

        @test LZ4HCCompressorStream <: TranscodingStream

        compressed = transcode(LZ4HCCompressor, text)
        @test sizeof(compressed) < sizeof(text)

        decompressed = transcode(LZ4SafeDecompressor, compressed)
        @test sizeof(decompressed) > sizeof(compressed)
        @test decompressed == Vector{UInt8}(text)

        test_roundtrip_fileio(LZ4HCCompressor, LZ4SafeDecompressor)
        test_roundtrip_transcode(LZ4HCCompressor, LZ4SafeDecompressor)

        file = IOBuffer(text)
        stream = LZ4SafeDecompressorStream(LZ4HCCompressorStream(file))
        flush(stream)

        @test hash(read(stream)) == hash(text)
        close(stream)
        close(file)

        file = IOBuffer(text)
        stream = LZ4SafeDecompressorStream(LZ4HCCompressorStream(file; compressionlevel = 5))
        flush(stream)

        @test hash(read(stream)) == hash(text)
        close(stream)
        close(file)


        file = IOBuffer("")
        stream = LZ4SafeDecompressorStream(LZ4HCCompressorStream(file))
        flush(stream)

        @test hash(read(stream)) == hash(b"")
        close(stream)
        close(file)
    end

    @testset "dst size fix" begin
        teststring = rand(UInt8, 800000)
        io = IOBuffer(teststring)
        stream = LZ4HCCompressorStream(io)
        result = read(stream)
        @test_nowarn close(stream)
        close(io)

        io = IOBuffer(result)
        stream = LZ4SafeDecompressorStream(io)
        result = read(stream)
        @test result == teststring
        @test_nowarn close(stream)
        close(io)
    end

end
