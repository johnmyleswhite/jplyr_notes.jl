"""
Construct a Table using keyword arguments to specify column names.
"""
function Table(; kwargs...) # ::Table
    n = length(kwargs)
    columns = Array(NullableVector, n)
    index_to_symbol = Array(Symbol, n)
    symbol_to_index = Dict{Symbol, Int}()
    # TODO: Make these steps atomic.
    for (i, (k, v)) in enumerate(kwargs)
        columns[i] = v
        symbol_to_index[k] = i
        index_to_symbol[i] = k
    end
    return Table(columns, index_to_symbol, symbol_to_index)
end
