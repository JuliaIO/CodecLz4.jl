using BinDeps
@BinDeps.setup
lz4 = library_dependency("lz4", aliases = ["lz4"])

if is_apple()
    if Pkg.installed("Homebrew") === nothing
        error("Homebrew package not installed, please run Pkg.add(\"Homebrew\")")
    end
    using Homebrew
    provides(Homebrew.HB, "lz4", lz4, os = :Darwin)
end