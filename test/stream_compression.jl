using LZ4
using TranscodingStreams:
    TranscodingStream,
    test_roundtrip_fileio,
    test_roundtrip_transcode

function compare(fp0::IO, fp1::IO)

    result = true

    while result 

        const MAXLEN = 1024
        r0 = read(fp0, MAXLEN)
        r1 = read(fp1, MAXLEN)
        
        result = r0 == r1

        if 0 == length(r0) || 0 == length(r1) 
            break;
        end

    end

    return result
end

@testset "stream_compression" begin
    input_filename = "test.txt"
    compressed_in_c = "compressed_in_c.lz4"
    lz4_filename = input_filename* ".lz4"
    dec_filename = lz4_filename* ".dec"

    in_fp = open(input_filename, "r")
    out_fp = open(lz4_filename, "w")
    @test_nowarn compress_stream(in_fp, out_fp)
    close(out_fp)
    close(in_fp)  

    in_fp = open(lz4_filename, "r")
    decFp = open(compressed_in_c, "r")
    @test compare(in_fp, decFp)
    close(decFp)
    close(in_fp)


    in_fp = open(compressed_in_c, "r")
    out_fp = open(dec_filename, "w")
    @test_nowarn decompress_stream(in_fp, out_fp)
    close(out_fp)
    close(in_fp)

    in_fp = open(input_filename, "r")
    decFp = open(dec_filename, "r")
    @test compare(in_fp, decFp)
    close(decFp)
    close(in_fp)

    rm(lz4_filename, force=true)
    rm(dec_filename, force=true)

end

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
    
end