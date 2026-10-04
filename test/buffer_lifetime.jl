using CodecLz4, Test

# Run separately: the probes specialize native bindings to force collection at entry.
const input_owner = Ref(WeakRef(nothing))
const probe_active = Ref(false)
const InputBuffer = Union{Ptr{UInt8}, Vector{UInt8}, Base.CodeUnits{UInt8}}
const OutputBuffer = Union{Ptr{UInt8}, Vector{UInt8}}

@noinline function native_entry(fn, args...)
    if probe_active[]
        GC.gc()
        live = input_owner[].value !== nothing
        @test live
        live || error("input owner collected before the native call")
    end
    invoke(fn, Tuple{Vararg{Any, length(args)}}, args...)
end

CodecLz4.LZ4_compress_fast(src::InputBuffer, dst::OutputBuffer, n::Integer, capacity::Integer, acceleration::Integer) =
    native_entry(CodecLz4.LZ4_compress_fast, src, dst, n, capacity, acceleration)
CodecLz4.LZ4_compress_HC(src::InputBuffer, dst::OutputBuffer, n::Integer, capacity::Integer, level::Integer) =
    native_entry(CodecLz4.LZ4_compress_HC, src, dst, n, capacity, level)
CodecLz4.LZ4_decompress_safe(src::InputBuffer, dst::OutputBuffer, n::Integer, capacity::Integer) =
    native_entry(CodecLz4.LZ4_decompress_safe, src, dst, n, capacity)

function temporary_input(n, string_input, encoded=false)
    probe_active[] = false
    data = UInt8[mod(i * 37, 256) for i in 1:n]
    encoded && (data = CodecLz4.lz4_compress(data))
    if string_input
        text = String(data)
        input_owner[] = WeakRef(text)
        probe_active[] = true
        return codeunits(text)
    end
    input_owner[] = WeakRef(data)
    probe_active[] = true
    data
end

compress_temporary(compress::F, n, string_input) where {F} =
    compress(temporary_input(n, string_input))
decompress_temporary(n, string_input) =
    CodecLz4.lz4_decompress(temporary_input(n, string_input, true), n)

@testset "Raw buffer lifetime" begin
    for n in (1, 4096, 1_000_000), string_input in (false, true)
        expected = UInt8[mod(i * 37, 256) for i in 1:n]
        for compress in (CodecLz4.lz4_compress, CodecLz4.lz4_hc_compress)
            @testset "$compress, $n bytes, string=$string_input" begin
                try
                    encoded = compress_temporary(compress, n, string_input)
                    probe_active[] = false
                    @test CodecLz4.lz4_decompress(encoded, n) == expected
                finally
                    probe_active[] = false
                end
            end
        end
        @testset "decompress, $n bytes, string=$string_input" begin
            try
                @test decompress_temporary(n, string_input) == expected
            finally
                probe_active[] = false
            end
        end
    end
end
