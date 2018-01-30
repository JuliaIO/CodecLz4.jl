using BinDeps
using Base.Libdl
@BinDeps.setup

function validate_lz4(name,handle)
    f = Libdl.dlsym_e(handle, "LZ4F_getVersion")
    return f != C_NULL
end

liblz4 = library_dependency("liblz4", validate = validate_lz4)
version = "1.8.1.2"

suffix = "$(Libdl.dlext).1.8.1"
if is_apple()
    suffix = "1.8.1.$(Libdl.dlext)"
end

# Best practice to use a fixed version here, either a version number tag or a git sha
# Please don't download "latest master" because the version that works today might not work tomorrow

provides(Sources, URI("https://github.com/lz4/lz4/archive/v$version.tar.gz"),
    liblz4, unpacked_dir="lz4-$version")

srcdir = joinpath(BinDeps.srcdir(liblz4), "lz4-$version")
prefix = joinpath(BinDeps.depsdir(liblz4), "usr")

provides(Binaries,
    URI("https://github.com/lz4/lz4/releases/download/v$version/llz4_v1_8_1_win$(Sys.ARCH).zip"),
    [liblz4], unpacked_dir=".",
    os = :Windows)



provides(SimpleBuild,
    (@build_steps begin
        GetSources(liblz4)
        CreateDirectory(joinpath(prefix, "lib"))
        @build_steps begin
            ChangeDirectory(srcdir)
            MAKE_CMD
            `mv lib/liblz4.$suffix "$prefix/lib/liblz4.$(Libdl.dlext)"`
        end
    end), liblz4, os = :Unix)

@BinDeps.install Dict(:liblz4 => :liblz4)