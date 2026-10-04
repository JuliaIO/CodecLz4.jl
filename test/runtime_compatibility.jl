using CodecLz4, TranscodingStreams, Test

@testset "Runtime compatibility" begin
    native_symbol() = CodecLz4.@gcsafe_ccall jl_symbol("codeclz4_runtime"::Cstring)::Symbol
    @test native_symbol() === :codeclz4_runtime

    for n in (0, 1, 17, 4096, 65_537)
        data = UInt8[mod(i * 37, 256) for i in 1:n]
        for compress in (CodecLz4.lz4_compress, CodecLz4.lz4_hc_compress)
            @test CodecLz4.lz4_decompress(compress(data), n) == data
        end
        for (encoder, decoder) in (
            (LZ4FrameCompressorStream, LZ4FrameDecompressorStream),
            (LZ4FastCompressorStream, LZ4SafeDecompressorStream),
            (LZ4HCCompressorStream, LZ4SafeDecompressorStream),
        )
            stream = decoder(encoder(IOBuffer(data)))
            try
                @test read(stream) == data
            finally
                close(stream)
            end
        end
    end

    data = UInt8[mod(i * 37, 256) for i in 1:4096]
    compressed = Vector{UInt8}(undef, 512)
    decoded = similar(data)
    size = Ref{Cint}(length(data))
    written = CodecLz4.LZ4_compress_destSize(data, compressed, size, length(compressed))
    @test 0 < size[] <= length(data)
    @test 0 < written <= length(compressed)
    @test CodecLz4.LZ4_decompress_safe(compressed, decoded, written, size[]) == size[]
    @test decoded[1:size[]] == data[1:size[]]
end
