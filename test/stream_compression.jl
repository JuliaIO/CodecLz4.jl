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