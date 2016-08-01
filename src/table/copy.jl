"""
Make a copy of a Table. Not a user-facing operation.
"""
function Base.copy(tbl::Table)::Table
    new_cols = Array(NullableVector, length(tbl.columns))
    for (j, col) in enumerate(tbl.columns)
        new_cols[j] = copy(col)
    end
    return Table(
        new_cols,
        copy(tbl.index_to_symbol),
        copy(tbl.symbol_to_index),
    )
end
