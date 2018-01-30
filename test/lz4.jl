
@testset "orig_lz4" begin
     str_ptr = LZ4_createStream()
     @test str_ptr != C_NULL
     err = LZ4_freeStream(str_ptr)
     @test err == 0

     test_in = "Far out in the uncharted backwaters of the unfashionable end of the west-
 ern  spiral  arm  of  the  Galaxy  lies  a  small  unregarded  yellow  sun."
     test_comp_out = Vector{UInt8}(1280)
     test_decomp_out = Vector{UInt8}(1280)
  
     len = LZ4_compress_default(test_in, test_comp_out, sizeof(test_in), sizeof(test_comp_out))
     @test len != 0

     err = LZ4_decompress_safe(test_comp_out, test_decomp_out, len, sizeof(test_decomp_out))
     @test err>0
     result = unsafe_string(pointer(test_decomp_out))
     @test result == test_in

     len = LZ4_compress_fast(test_in, test_comp_out, sizeof(test_in), sizeof(test_comp_out), 5)
 	@test len != 0
 	err = LZ4_decompress_safe(test_comp_out, test_decomp_out, len, sizeof(test_decomp_out))
     @test err>0 
     result = unsafe_string(pointer(test_decomp_out))
     @test result == test_in
end