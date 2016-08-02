"""
Group-by tuple func indexer
"""
@noinline function _group_by_tuple_func(f, tbl, colnames)
    # Extract the columns from the table and create a tuple iterator.
    cols = [tbl[colname] for colname in colnames]
    tpl_itr = zip(cols...)

    # Pre-allocate the table's new column.
    # TODO: Type this more strongly when possible.
    group_indices = Dict{Any, Vector{Int}}()

    # Fill the new column in row-by-row.
    _grow_indices!(group_indices, f, tpl_itr)

    # Return the output
    return group_indices
end
