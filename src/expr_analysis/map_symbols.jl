"""
Produce a mapping from symbols to numeric indices and a reverse mapping from
numeric indices to symbols.

Arguments:

* s::Set{Symbol}: A set of symbols that should be assigned numeric indices.

Returns:

* mapping::Dict{Symbol, Int}: A mapping from symbols to indices.
* reverse_mapping::Vector{Symbol}: A mapping from indices to symbols.
"""
function map_symbols(s::Set{Symbol})::Tuple{Dict{Symbol, Int}, Vector{Symbol}}
    mapping = Dict{Symbol, Int}()
    reverse_mapping = Array(Symbol, length(s))

    for (i, sym) in enumerate(s)
        mapping[sym] = i
        reverse_mapping[i] = sym
    end

    return mapping, reverse_mapping
end
