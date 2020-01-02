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

        @test read(stream) == text
        close(stream)
        close(file)

        file = IOBuffer(text)
        stream = LZ4SafeDecompressorStream(LZ4HCCompressorStream(file; compressionlevel = 5))
        flush(stream)

        @test read(stream) == text
        close(stream)
        close(file)


        file = IOBuffer("")
        stream = LZ4SafeDecompressorStream(LZ4HCCompressorStream(file))
        flush(stream)

        @test read(stream) == b""
        close(stream)
        close(file)

        teststring = rand(UInt8, 10000)
        file = IOBuffer(teststring)
        stream = LZ4SafeDecompressorStream(LZ4HCCompressorStream(file; block_size = 2048); block_size = 2048)
        flush(stream)

        @test read(stream) == teststring
        close(stream)
        close(file)
    end

    @testset "Errors" begin
        # Uninitialized
        input = Memory(Vector{UInt8}(text))
        output = Memory(Vector{UInt8}(undef, 1280))
        not_initialized = LZ4HCCompressor()
        @test TranscodingStreams.startproc(not_initialized, :read, Error()) == :error
        @test TranscodingStreams.process(not_initialized, input, output, Error()) == (0, 0, :error)

        # Compression into too-small buffer
        output = Memory(Vector{UInt8}(undef, 1))
        compressor = LZ4HCCompressor()
        try
            @test_nowarn TranscodingStreams.initialize(compressor)
            @test TranscodingStreams.startproc(compressor, :read, Error()) == :ok
            err = Error()
            @test TranscodingStreams.process(compressor, input, output, err) == (0, 0, :error)

            @test err[] isa BoundsError
        finally
            TranscodingStreams.finalize(compressor)
        end

        # Block size too large
        @test_throws ArgumentError LZ4HCCompressor(; block_size = CodecLz4.LZ4_MAX_INPUT_SIZE + 1)
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
