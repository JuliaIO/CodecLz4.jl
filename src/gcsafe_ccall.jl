## version of ccall that calls jl_gc_safe_enter|leave around the inner ccall
# note that this is generally only safe with functions that do not call back into
# Julia

const HAS_CCALL_GCSAFE = VERSION >= v"1.13.0-DEV.70" || v"1.12-DEV.2029" <= VERSION < v"1.13-"

"""
    @gcsafe_ccall ...

Call a foreign function just like [`@ccall`](https://docs.julialang.org/en/v1/base/c/#Base.@ccall),
but marking it safe for the GC to run. This is useful for functions that may block, so that the GC
isn't blocked from running, but may also be required to prevent deadlocks (see JuliaGPU/CUDA.jl#2261).

Note that this is generally only safe with non-Julia C functions that do not call back into Julia
directly.

On Julia versions predating `@ccall`, only fixed-argument calls to a function
symbol or a library-qualified name are supported.
"""
macro gcsafe_ccall end

if HAS_CCALL_GCSAFE
    macro gcsafe_ccall(expr)
        exprs = Any[:(gc_safe = true), expr]
        return Base.ccall_macro_lower((:ccall), Base.ccall_macro_parse(exprs)...)
    end
else
    function parse_ccall(expr)
        if isdefined(Base, :ccall_macro_parse)
            return Base.ccall_macro_parse(expr)
        end
        call, rettype = expr.args
        name = call.args[1]
        func = name isa Symbol ? QuoteNode(name) : Expr(:tuple, name.args[2], name.args[1])
        args = call.args[2:end]
        return func, rettype, [arg.args[2] for arg in args], [arg.args[1] for arg in args], 0
    end

    function ccall_macro_lower(func, rettype, types, args, nreq)
        # instead of re-using ccall or Expr(:foreigncall) to perform argument conversion,
        # we need to do so ourselves in order to insert a jl_gc_safe_enter|leave
        # just around the inner ccall

        cconvert_exprs = []
        cconvert_args = []
        for (typ, arg) in zip(types, args)
            var = gensym("$(func)_cconvert")
            push!(cconvert_args, var)
            push!(cconvert_exprs, :($var = Base.cconvert($(esc(typ)), $(esc(arg)))))
        end

        unsafe_convert_exprs = []
        unsafe_convert_args = []
        for (typ, arg) in zip(types, cconvert_args)
            var = gensym("$(func)_unsafe_convert")
            push!(unsafe_convert_args, var)
            push!(unsafe_convert_exprs, :($var = Base.unsafe_convert($(esc(typ)), $arg)))
        end

        call = quote
            $(unsafe_convert_exprs...)

            gc_state = ccall(:jl_gc_safe_enter, Int8, ())
            ret = ccall(
                $(esc(func)), $(esc(rettype)), $(Expr(:tuple, map(esc, types)...)),
                $(unsafe_convert_args...)
            )
            ccall(:jl_gc_safe_leave, Cvoid, (Int8,), gc_state)
            ret
        end

        return quote
            @static if VERSION >= v"1.8"
                @inline
            end
            $(cconvert_exprs...)
            GC.@preserve $(cconvert_args...) $(call)
        end
    end

    macro gcsafe_ccall(expr)
        return ccall_macro_lower(parse_ccall(expr)...)
    end
end # HAS_CCALL_GCSAFE
