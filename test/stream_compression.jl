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
    inpFilename = "test.txt"
    compressedInC = "compressed_in_c.lz4"
    lz4Filename = inpFilename* ".lz4"
    decFilename = lz4Filename* ".dec"

    inpFp = open(inpFilename, "r")
    outFp = open(lz4Filename, "w")
    @test_nowarn compress_stream(inpFp, outFp)
    close(outFp)
    close(inpFp)  

    inpFp = open(lz4Filename, "r")
    decFp = open(compressedInC, "r")
    @test compare(inpFp, decFp)
    close(decFp)
    close(inpFp)


    inpFp = open(compressedInC, "r")
    outFp = open(decFilename, "w")
    @test_nowarn decompress_stream(inpFp, outFp)
    close(outFp)
    close(inpFp)

    inpFp = open(inpFilename, "r")
    decFp = open(decFilename, "r")
    @test compare(inpFp, decFp)
    close(decFp)
    close(inpFp)

    rm(lz4Filename, force=true)
    rm(decFilename, force=true)

end