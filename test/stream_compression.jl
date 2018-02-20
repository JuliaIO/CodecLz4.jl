using TranscodingStreams: TranscodingStream, Error, Memory,
    test_roundtrip_fileio, test_roundtrip_transcode
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

    @test LZ4CompressorStream <: TranscodingStream
    @test LZ4DecompressorStream <: TranscodingStream

    compressed = transcode(LZ4Compressor, Vector{UInt8}(text))
    @test sizeof(compressed) < sizeof(text)

    decompressed = transcode(LZ4Decompressor, compressed)
    @test sizeof(decompressed) > sizeof(compressed)
    @test decompressed == Vector{UInt8}(text)

    #test_roundtrip_fileio(LZ4Compressor, LZ4Decompressor)
    #test_roundtrip_transcode(LZ4Compressor, LZ4Decompressor)

    file = IOBuffer(text)
    stream = LZ4DecompressorStream(LZ4CompressorStream(file))
    flush(stream)

    @test hash(read(stream)) == hash(text)
    close(stream)
    close(file)

    file = IOBuffer(text)
    stream = LZ4DecompressorStream(LZ4CompressorStream(file; blocksizeid = max64KB))
    flush(stream)

    @test hash(read(stream)) == hash(text)
    close(stream)
    close(file)


    file = IOBuffer("")
    stream = LZ4DecompressorStream(LZ4CompressorStream(file))
    flush(stream)

    @test hash(read(stream)) == hash(b"")
    close(stream)
    close(file)
end

@testset "Errors" begin
    input = Memory(Vector{UInt8}(text))
    output = Memory(Vector{UInt8}(uninitialized, 1280))
    not_initialized = LZ4Compressor()
    @test TranscodingStreams.startproc(not_initialized, :read, Error()) == :error
    @test TranscodingStreams.process(not_initialized, input, output, Error()) == (0, 0, :error)

    compressed = transcode(LZ4Compressor, Vector{UInt8}(text))
    corrupted = copy(compressed)
    corrupted[1] = 0x00
    file = IOBuffer(corrupted)
    stream = LZ4DecompressorStream(file)
    @test_throws ErrorException read(stream)
    @test_throws ArgumentError read(stream)

    output = Memory(Vector{UInt8}(uninitialized, 1))
    compressor = LZ4Compressor()
    @test_nowarn TranscodingStreams.initialize(compressor)
    @test TranscodingStreams.startproc(compressor, :read, Error()) == :ok
    err = Error()
    @test TranscodingStreams.process(compressor, input, output, err) == (0, 0, :error)
    @test err[].msg == "Output buffer too small for header."
end
