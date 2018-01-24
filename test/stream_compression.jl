function compare(fp0::IO, fp1::IO)

    result = true

    while result 

        b0 = Vector{UInt8}(1024)
        b1 = Vector{UInt8}(1024)
        r0 = readbytes!(fp0, b0, length(b0))
        r1 = readbytes!(fp1, b1, length(b1))
        
        result = r0 == r1

        if (0 == r0 || 0 == r1) 
            break;
        end
        
        if (result) 
            result = b0==b1
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
    @test_broken compare(inpFp, decFp)
    close(decFp)
    close(inpFp)


    inpFp = open(compressedInC, "r")
    outFp = open(decFilename, "w")
    @test_broken decompress_stream(inpFp, outFp)
    close(outFp)
    close(inpFp)

    inpFp = open(inpFilename, "r")
    decFp = open(decFilename, "r")
    @test_broken compare(inpFp, decFp)
    close(decFp)
    close(inpFp)

    rm(lz4Filename, force=true)
    rm(decFilename, force=true)

end