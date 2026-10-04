@testset "lz4_compression" begin
    text = b"""
    Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aenean sollicitudin
    mauris non nisi consectetur, a dapibus urna pretium. Vestibulum non posuere
    erat. Donec luctus a turpis eget aliquet. Cras tristique iaculis ex, eu
    malesuada sem interdum sed. Vestibulum ante ipsum primis in faucibus orci luctus
    et ultrices posuere cubilia Curae; Etiam volutpat, risus nec gravida ultricies,
    erat ex bibendum ipsum, sed varius ipsum ipsum vitae dui.
    """

    @testset "Transcoding" begin
        @test LZ4FastCompressorStream <: TranscodingStream
        @test LZ4SafeDecompressorStream <: TranscodingStream

        compressed = transcode(LZ4FastCompressor, text)
        @test sizeof(compressed) < sizeof(text)

        decompressed = transcode(LZ4SafeDecompressor, compressed)
        @test sizeof(decompressed) > sizeof(compressed)
        @test decompressed == Vector{UInt8}(text)

        test_roundtrip_fileio(LZ4FastCompressor, LZ4SafeDecompressor)
        test_roundtrip_transcode(LZ4FastCompressor, LZ4SafeDecompressor)

        file = IOBuffer(text)
        stream = LZ4SafeDecompressorStream(LZ4FastCompressorStream(file))
        flush(stream)

        @test read(stream) == text
        close(stream)
        close(file)

        file = IOBuffer(text)
        stream = LZ4SafeDecompressorStream(LZ4FastCompressorStream(file; acceleration = 5))
        flush(stream)

        @test read(stream) == text
        close(stream)
        close(file)

        file = IOBuffer("")
        stream = LZ4SafeDecompressorStream(LZ4FastCompressorStream(file))
        flush(stream)

        @test read(stream) == b""
        close(stream)
        close(file)

        teststring = rand(UInt8, 10000)
        file = IOBuffer(teststring)
        stream = LZ4SafeDecompressorStream(LZ4FastCompressorStream(file; block_size = 2048); block_size = 2048)
        flush(stream)

        @test read(stream) == teststring
        close(stream)
        close(file)
    end

    @testset "Errors" begin
        @testset "Uninitialized" begin
            input_data = Vector{UInt8}(text)
            output_data = Vector{UInt8}(undef, 1280)
            GC.@preserve input_data output_data begin
                input = Memory(pointer(input_data), length(input_data))
                output = Memory(pointer(output_data), length(output_data))
                not_initialized = LZ4FastCompressor()
                @test TranscodingStreams.startproc(not_initialized, :read, Error()) == :error
                @test TranscodingStreams.process(not_initialized, input, output, Error()) == (0, 0, :error)

                compressed_data = transcode(LZ4FastCompressor, text)
                GC.@preserve compressed_data begin
                    compressed = Memory(pointer(compressed_data), length(compressed_data))
                    not_initialized = LZ4SafeDecompressor()
                    @test TranscodingStreams.startproc(not_initialized, :read, Error()) == :error
                    @test TranscodingStreams.process(not_initialized, compressed, output, Error()) == (0, 0, :error)
                end
            end
        end

        @testset "Bad Input" begin
            # Malformed decompression input
            @test_throws CodecLz4.LZ4Exception transcode(LZ4SafeDecompressor, text)
            @test_throws BoundsError transcode(LZ4SafeDecompressor, [0x00])

            # Properly compressed but not formatted as a stream
            compressed = lz4_compress(text)
            @test_throws CodecLz4.LZ4Exception transcode(LZ4SafeDecompressor, text)

            # Block size too large
            @test_throws ArgumentError LZ4FastCompressor(; block_size = CodecLz4.LZ4_MAX_INPUT_SIZE + 1)
        end

        @testset "Bad Buffer Size" begin
            # Decompression with too-small block_size
            output_data = Vector{UInt8}(undef, 1024)
            compressed_data = transcode(LZ4FastCompressor, text)
            GC.@preserve output_data compressed_data begin
                output = Memory(pointer(output_data), length(output_data))
                compressed = Memory(pointer(compressed_data), length(compressed_data))
                decompressor = LZ4SafeDecompressor(; block_size = 200)
                try
                    @test_nowarn TranscodingStreams.initialize(decompressor)
                    @test TranscodingStreams.startproc(decompressor, :read, Error()) == :ok
                    err = Error()
                    @test TranscodingStreams.process(decompressor, compressed, output, err) == (0, 0, :error)

                    @test err[] isa CodecLz4.LZ4Exception
                    @test err[].msg == "Decompression failed."
                finally
                    TranscodingStreams.finalize(decompressor)
                end
            end

            # Compression into too-small buffer
            input_data = Vector{UInt8}(text)
            output_data = Vector{UInt8}(undef, 1)
            GC.@preserve input_data output_data begin
                input = Memory(pointer(input_data), length(input_data))
                output = Memory(pointer(output_data), length(output_data))
                compressor = LZ4FastCompressor()

                try
                    @test_nowarn TranscodingStreams.initialize(compressor)
                    @test TranscodingStreams.startproc(compressor, :read, Error()) == :ok
                    err = Error()
                    @test TranscodingStreams.process(compressor, input, output, err) == (0, 0, :error)

                    @test err[] isa BoundsError
                finally
                    TranscodingStreams.finalize(compressor)
                end
            end

            # Decompression into too-small buffer
            output_data = Vector{UInt8}(undef, 1)
            compressed_data = transcode(LZ4FastCompressor, text)
            GC.@preserve output_data compressed_data begin
                output = Memory(pointer(output_data), length(output_data))
                compressed = Memory(pointer(compressed_data), length(compressed_data))
                decompressor = LZ4SafeDecompressor()
                try
                    @test_nowarn TranscodingStreams.initialize(decompressor)
                    @test TranscodingStreams.startproc(decompressor, :read, Error()) == :ok
                    err = Error()
                    @test TranscodingStreams.process(decompressor, compressed, output, err) == (0, 0, :error)

                    @test err[] isa BoundsError
                finally
                    TranscodingStreams.finalize(decompressor)
                end
            end
        end
    end

    @testset "dst size fix" begin
        teststring = rand(UInt8, 800000)
        io = IOBuffer(teststring)
        stream = LZ4FastCompressorStream(io)
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
