# LZ4

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://morris25.github.io/LZ4.jl/stable)
[![Latest](https://img.shields.io/badge/docs-latest-blue.svg)](https://morris25.github.io/LZ4.jl/latest)
[![Build Status](https://travis-ci.org/morris25/LZ4.jl.svg?branch=master)](https://travis-ci.org/morris25/LZ4.jl)
[![Build Status](https://ci.appveyor.com/api/projects/status/github/morris25/LZ4.jl?svg=true)](https://ci.appveyor.com/project/morris25/LZ4-jl)
[![CodeCov](https://codecov.io/gh/morris25/LZ4.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/morris25/LZ4.jl)

Provides a transcoding codec for LZ4. Source: [LZ4](https://github.com/lz4/lz4)

## Installation

```julia
Pkg.add("LZ4")
```

## Usage

```julia
using LZ4

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
stream = LZ4CompressorStream(IOBuffer(text))
for line in eachline(LZ4DecompressorStream(stream))
println(line)
end
close(stream)

# Array API.
compressed = transcode(LZ4Compressor, text)
@assert sizeof(compressed) < sizeof(text)
@assert transcode(LZ4Decompressor, compressed) == Vector{UInt8}(text)
```
The API is based off of [CodecZLib](https://github.com/bicycle1885/CodecZlib.jl), and uses [TranscodingStreams.jl](https://github.com/bicycle1885/TranscodingStreams.jl). See those for details.
