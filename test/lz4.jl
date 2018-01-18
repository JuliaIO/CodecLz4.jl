
@testset "orig_lz4" begin
     strPtr = LZ4_createStream()
     @test strPtr != C_NULL
     err = LZ4_freeStream(strPtr)
     @test err == 0

     testIn = "Far out in the uncharted backwaters of the unfashionable end of the west-
 ern  spiral  arm  of  the  Galaxy  lies  a  small  unregarded  yellow  sun."
     testCompOut = Vector{UInt8}(1280)
     testDeCompOut = Vector{UInt8}(1280)
  
     len = LZ4_compress_default(testIn, testCompOut, sizeof(testIn), sizeof(testCompOut))
     @test len != 0

     err = LZ4_decompress_safe(testCompOut, testDeCompOut, len, sizeof(testDeCompOut))
     @test err>0
     result = unsafe_string(pointer(testDeCompOut))
     @test result == testIn

     len = LZ4_compress_fast(testIn, testCompOut, sizeof(testIn), sizeof(testCompOut), 5)
 	@test len != 0
 	err = LZ4_decompress_safe(testCompOut, testDeCompOut, len, sizeof(testDeCompOut))
     @test err>0 
     result = unsafe_string(pointer(testDeCompOut))
     @test result == testIn
end