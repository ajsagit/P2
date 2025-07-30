
"""
    getcompressor(n::Union{Integer,Meta.CompressionCodec})

Get the function `𝒻(::AbstractVector{UInt8})::AbstractVector{UInt8}` for compressing data to codec `n`.
"""
function getcompressor(c::Meta.CompressionCodec, level=nothing)
    if c == Meta.UNCOMPRESSED
        identity
    elseif c == Meta.SNAPPY
        Snappy.compress ∘ Vector
    elseif c == Meta.GZIP
        v -> transcodewrapper(isnothing(level) ? GzipCompressor() : GzipCompressor(; level), v)
    elseif c == Meta.ZSTD
        v -> transcodewrapper(isnothing(level) ? ZstdCompressor() : ZstdCompressor(; level), v)
    elseif c == Meta.LZ4_RAW
        # we don't currently support but this allows loading as empty col
        v -> throw(ArgumentError("lz4 compression codec not yet implemented"))
    else
        throw(ArgumentError("compression codec $c is unsupported"))
    end
end
getcompressor(c::Integer, level=nothing) = getcompressor(Meta.CompressionCodec(c), level)

function transcodewrapper(codec, value)::Vector{UInt8}
    # initialize and finalize com from TranscodingStreams
    # which is implemented by both GzipCompressor and ZstdCompressor
    CodecZstd.initialize(codec)
    out = transcode(codec, Vector(value))
    CodecZstd.finalize(codec)
    return out
end

"""
    getdecompressor(n::Union{Integer,Meta.CompressionCodec})

Get the function `𝒻(::AbstractVector{UInt8})::AbstractVector{UInt8}` for decompressing data from codec `n`.
"""
function getdecompressor(c::Meta.CompressionCodec)
    if c == Meta.UNCOMPRESSED
        identity
    elseif c == Meta.SNAPPY
        Snappy.uncompress ∘ Vector
    elseif c == Meta.GZIP
        v -> transcode(GzipDecompressor, Vector(v))
    elseif c == Meta.ZSTD
        v -> transcode(ZstdDecompressor, Vector(v))
    elseif c == Meta.LZ4_RAW
        lz4_decompress ∘ Vector
    else
        throw(ArgumentError("compression codec $c is unsupported"))
    end
end

# need this to support symbol options
function _compression_codec(s::Symbol)
    if s == :uncompressed
        Meta.UNCOMPRESSED
    elseif s == :snappy
        Meta.SNAPPY
    elseif s == :gzip
        Meta.GZIP
    elseif s == :lzo
        Meta.LZO
    elseif s == :brotli
        Meta.BROTLI
    elseif s == :lz4
        Meta.LZ4
    elseif s == :zstd
        Meta.ZSTD
    elseif s == :lz4_raw
        Meta.LZ4_RAW
    else
        throw(ArgumentError("invalid or unsupported compression codec $s"))
    end
end
_compression_codec(c::Meta.CompressionCodec) = c
