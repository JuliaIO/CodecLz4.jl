using TranscodingStreams: TranscodingStream, Error, Memory
using TestsForCodecPackages: test_roundtrip_fileio, test_roundtrip_transcode
using TranscodingStreams

text = b"""
Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aenean sollicitudin
mauris non nisi consectetur, a dapibus urna pretium. Vestibulum non posuere
erat. Donec luctus a turpis eget aliquet. Cras tristique iaculis ex, eu
malesuada sem interdum sed. Vestibulum ante ipsum primis in faucibus orci luctus
et ultrices posuere cubilia Curae; Etiam volutpat, risus nec gravida ultricies,
erat ex bibendum ipsum, sed varius ipsum ipsum vitae dui.
"""

@testset "Transcoding" begin
    @test LZ4FrameCompressorStream <: TranscodingStream
    @test LZ4FrameDecompressorStream <: TranscodingStream

    compressed = transcode(LZ4FrameCompressor, text)
    @test sizeof(compressed) < sizeof(text)

    decompressed = transcode(LZ4FrameDecompressor, compressed)
    @test sizeof(decompressed) > sizeof(compressed)
    @test decompressed == Vector{UInt8}(text)

    test_roundtrip_fileio(LZ4FrameCompressor, LZ4FrameDecompressor)
    test_roundtrip_transcode(LZ4FrameCompressor, LZ4FrameDecompressor)

    file = IOBuffer(text)
    stream = LZ4FrameDecompressorStream(LZ4FrameCompressorStream(file))
    flush(stream)

    @test hash(read(stream)) == hash(text)
    close(stream)
    close(file)

    file = IOBuffer(text)
    stream = LZ4FrameDecompressorStream(LZ4FrameCompressorStream(file; blocksizeid = max64KB))
    flush(stream)

    @test hash(read(stream)) == hash(text)
    close(stream)
    close(file)


    file = IOBuffer("")
    stream = LZ4FrameDecompressorStream(LZ4FrameCompressorStream(file))
    flush(stream)

    @test hash(read(stream)) == hash(b"")
    close(stream)
    close(file)
end

@testset "Errors" begin
    input_data = Vector{UInt8}(text)
    output_data = Vector{UInt8}(undef, 1280)
    GC.@preserve input_data output_data begin
        input = Memory(pointer(input_data), length(input_data))
        output = Memory(pointer(output_data), length(output_data))
        not_initialized = LZ4FrameCompressor()
        @test TranscodingStreams.startproc(not_initialized, :read, Error()) == :error
        @test TranscodingStreams.process(not_initialized, input, output, Error()) == (0, 0, :error)

        compressed = transcode(LZ4FrameCompressor, Vector{UInt8}(text))
        corrupted = copy(compressed)
        corrupted[1] = 0x00
        file = IOBuffer(corrupted)
        stream = LZ4FrameDecompressorStream(file)
        @test_throws CodecLz4.LZ4Exception read(stream)
        @test_throws ArgumentError read(stream)

        output = Memory(pointer(output_data), 1)
        compressor = LZ4FrameCompressor()
        @test_nowarn TranscodingStreams.initialize(compressor)
        @test TranscodingStreams.startproc(compressor, :read, Error()) == :ok
        err = Error()
        @test TranscodingStreams.process(compressor, input, output, err) == (0, 0, :error)
        @test err[].msg == "Output buffer too small for header."
        @test_nowarn TranscodingStreams.finalize(compressor)
    end

    codec = LZ4FrameDecompressor()
    @test_throws CodecLz4.LZ4Exception transcode(codec, "not properly formatted")
    @test_nowarn TranscodingStreams.finalize(codec)
end

@testset "keywords" begin
    compressor = LZ4FrameCompressor(
        blocksizeid = max64KB,
        blockmode = block_independent,
        contentchecksum = true,
        blockchecksum = true,
        frametype = skippable_frame,
        contentsize = 100,
        compressionlevel=5,
        autoflush = true
        )

    prefs = compressor.prefs[]
    @test prefs.compressionLevel == Cint(5)
    @test prefs.autoFlush == Cuint(1)
    @test prefs.reserved == (Cuint(0), Cuint(0), Cuint(0), Cuint(0))

    frame = prefs.frameInfo
    @test frame.blockSizeID == Cuint(4)
    @test frame.blockMode == Cuint(1)
    @test frame.contentChecksumFlag == Cuint(1)
    @test frame.frameType == Cuint(1)
    @test frame.contentSize == Culonglong(100)
    @test frame.blockChecksumFlag == Cuint(1)
end

@testset "dst size fix" begin
    teststring = rand(UInt8, 800000)
    io = IOBuffer(teststring)
    stream = LZ4FrameCompressorStream(io)
    result = read(stream)
    @test_nowarn close(stream)
    close(io)

    io = IOBuffer(result)
    stream = LZ4FrameDecompressorStream(io)
    result = read(stream)
    @test result == teststring
    @test_nowarn close(stream)
    close(io)
end
