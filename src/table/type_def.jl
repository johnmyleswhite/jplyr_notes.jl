"""
A Table object is a specific in-memory representation of tabular data. It
supports the relational algebra API of jplyr.
"""
immutable Table
    columns::Vector{NullableVector}
    index_to_symbol::Vector{Symbol}
    symbol_to_index::Dict{Symbol, Int}

    function Table(columns, index_to_symbol, symbol_to_index)
        ncols = length(columns)
        nrows = 0
        for (i, col) in enumerate(columns)
            if i == 1
                nrows = length(col)
            else
                if nrows != length(col)
                    error("All columns must have the same length")
                end
            end
        end
        if length(index_to_symbol) != ncols || length(symbol_to_index) != ncols
            error("Table components must all")
        end
        return new(columns, index_to_symbol, symbol_to_index)
    end
end
