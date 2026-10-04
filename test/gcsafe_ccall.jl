using CodecLz4
using InteractiveUtils

@testset "gcsafe_ccall" begin
    function gc_safe_ccall()
        # jl_symbol is marked as JL_NOTSAFEPOINT
        CodecLz4.@gcsafe_ccall jl_symbol("gc_safe_ccall"::Cstring)::Symbol
    end

    let llvm = sprint(code_llvm, gc_safe_ccall, ())
        # check that the call works
        @test gc_safe_ccall() isa Symbol
        # v1.10 is hard to test since ccall are just raw runtime pointers
        if VERSION >= v"1.11"
            if !CodecLz4.HAS_CCALL_GCSAFE
                # check for the gc_safe store
                @test occursin("jl_gc_safe_enter", llvm)
                @test occursin("jl_gc_safe_leave", llvm)
            else
                @test occursin("store atomic i8 2", llvm)
            end
        end
    end
end
