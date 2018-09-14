using BinDeps
using Compat.Libdl
using Base.Sys: WORD_SIZE
import Compat.Sys
@BinDeps.setup

function validate_lz4(name,handle)
    f = Libdl.dlsym_e(handle, "LZ4F_getVersion")
    return f != C_NULL
end

liblz4 = library_dependency("liblz4", validate = validate_lz4)

long_version = "1.8.1.2"
short_version = "1.8.1"
zipname = "lz4_v$(replace(short_version, "." => "_"))_win$(WORD_SIZE).zip"

suffix = "so.$short_version"
if Sys.isapple()
    suffix = "$short_version.$(Libdl.dlext)"
end

# Best practice to use a fixed long_version here, either a long_version number tag or a git sha
# Please don't download "latest master" because the version that works today might not work tomorrow

provides(Sources, URI("https://github.com/lz4/lz4/archive/v$long_version.tar.gz"),
    liblz4, unpacked_dir="lz4-$long_version", os = :Unix)

srcdir = joinpath(BinDeps.srcdir(liblz4), "lz4-$long_version")

provides(SimpleBuild,
    (@build_steps begin
        GetSources(liblz4)
        CreateDirectory(BinDeps.libdir(liblz4))
        @build_steps begin
            ChangeDirectory(srcdir)
            MAKE_CMD
            `mv lib/liblz4.$suffix "$(BinDeps.libdir(liblz4))/liblz4.$(Libdl.dlext)"`
        end
    end), liblz4, os = :Unix)

provides(BuildProcess,
    (@build_steps begin
        FileDownloader("https://github.com/lz4/lz4/releases/download/v$long_version/$zipname",
        joinpath(BinDeps.downloadsdir(liblz4), zipname))
        CreateDirectory(BinDeps.srcdir(liblz4), true)
        FileUnpacker(joinpath(BinDeps.downloadsdir(liblz4), zipname), BinDeps.srcdir(liblz4), "dll")
        CreateDirectory(BinDeps.libdir(liblz4), true)
        @build_steps begin
            ChangeDirectory(joinpath(BinDeps.srcdir(liblz4), "dll"))
            `powershell cp "liblz4.$suffix.$(Libdl.dlext)" $(joinpath(BinDeps.libdir(liblz4),"liblz4.$(Libdl.dlext)"))`
        end
    end), liblz4, os = :Windows)

if Sys.iswindows()
    push!(BinDeps.defaults, BuildProcess)
    @BinDeps.install Dict(:liblz4 => :liblz4)
    pop!(BinDeps.defaults)
else
    @BinDeps.install Dict(:liblz4 => :liblz4)
end
