using TranscodingStreams: TranscodingStream, TranscodingStreams, Error, Memory,
    test_roundtrip_fileio, test_roundtrip_transcode

@testset "transcoding" begin

    @test LZ4CompressorStream <: TranscodingStream
    @test LZ4DecompressorStream <: TranscodingStream
    text = b"""
Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aenean sollicitudin
mauris non nisi consectetur, a dapibus urna pretium. Vestibulum non posuere
erat. Donec luctus a turpis eget aliquet. Cras tristique iaculis ex, eu
malesuada sem interdum sed. Vestibulum ante ipsum primis in faucibus orci luctus
et ultrices posuere cubilia Curae; Etiam volutpat, risus nec gravida ultricies,
erat ex bibendum ipsum, sed varius ipsum ipsum vitae dui.
"""

    compressed = transcode(LZ4Compressor, text)
    @test sizeof(compressed) < sizeof(text)

    corrupted = copy(compressed)
    corrupted[1] = 0x00
    file = IOBuffer(corrupted)
    stream = LZ4DecompressorStream(file)
    @test_throws ErrorException read(stream)
    @test_throws ArgumentError read(stream)

    decompressed = transcode(LZ4Decompressor, compressed)
    @test sizeof(decompressed) > sizeof(compressed)
    @test decompressed == Vector{UInt8}(text)

    test_roundtrip_fileio(LZ4Compressor, LZ4Decompressor)
    test_roundtrip_transcode(LZ4Compressor, LZ4Decompressor)


    file = IOBuffer(text)
    stream = LZ4DecompressorStream(LZ4CompressorStream(file))
    flush(stream)

    @test hash(read(stream)) == hash(text)
    close(stream)
    close(file)

    file = IOBuffer(text)
    stream = LZ4DecompressorStream(LZ4CompressorStream(file; blocksizeid = UInt32(4)))
    flush(stream)

    @test hash(read(stream)) == hash(text)
    close(stream)
    close(file)

    input = Memory(Vector{UInt8}(text))
    output = Memory(Vector{UInt8}(1280))
    not_initialized = LZ4Compressor()
    @test TranscodingStreams.startproc(not_initialized, :read, Error()) == :error
    @test TranscodingStreams.process(not_initialized, input, output, Error()) == (0, 0, :error)


    file = IOBuffer("")
    stream = LZ4DecompressorStream(LZ4CompressorStream(file))
    flush(stream)

    @test hash(read(stream)) == hash(b"")
    close(stream)
    close(file)
end
