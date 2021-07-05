# CodecLz4

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://juliaio.github.io/CodecLz4.jl/stable)
[![Latest](https://img.shields.io/badge/docs-latest-blue.svg)](https://juliaio.github.io/CodecLz4.jl/latest)
[![Build Status](https://travis-ci.com/JuliaIO/CodecLz4.jl.svg?branch=master)](https://travis-ci.com/JuliaIO/CodecLz4.jl)
[![CodeCov](https://codecov.io/gh/JuliaIO/CodecLz4.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/JuliaIO/CodecLz4.jl)

Provides transcoding codecs for compression and decompression with LZ4. Source: [LZ4](https://github.com/lz4/lz4)
The compression algorithm is similar to the compression available through [Blosc.jl](https://github.com/stevengj/Blosc.jl), but uses the LZ4 Frame format as opposed to the standard LZ4 or LZ4_HC formats.

Codecs for the standard LZ4 and LZ4_HC formats are also provided as `LZ4FastCompressor` and `LZ4HCCompressor`.
These codecs follow the [LZ4 streaming examples](https://github.com/lz4/lz4/tree/master/examples),
breaking the data into blocks and prepending each compressed block with a size.
Data compressed with these codecs can be decompressed with `LZ4SafeDecompressor`.

Non-streaming functions are included via `lz4_compress`, `lz4_hc_compress`, and `lz4_decompress`.
These should work with most other standard lz4 implementations.

## Installation

```julia
Pkg.add("CodecLz4")
```

## Usage

```julia
using CodecLz4

# Some text.
text = """
Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aenean sollicitudin
mauris non nisi consectetur, a dapibus urna pretium. Vestibulum non posuere
erat. Donec luctus a turpis eget aliquet. Cras tristique iaculis ex, eu
malesuada sem interdum sed. Vestibulum ante ipsum primis in faucibus orci luctus
et ultrices posuere cubilia Curae; Etiam volutpat, risus nec gravida ultricies,
erat ex bibendum ipsum, sed varius ipsum ipsum vitae dui.
"""

# Streaming API.
stream = LZ4FrameCompressorStream(IOBuffer(text))
for line in eachline(LZ4FrameDecompressorStream(stream))
println(line)
end
close(stream)

# Array API.
compressed = transcode(LZ4FrameCompressor, text)
@assert sizeof(compressed) < sizeof(text)
@assert transcode(LZ4FrameDecompressor, compressed) == Vector{UInt8}(text)
```
The API is heavily based off of [CodecZLib](https://github.com/JuliaIO/CodecZlib.jl), and uses [TranscodingStreams.jl](https://github.com/JuliaIO/TranscodingStreams.jl). See those for details.
