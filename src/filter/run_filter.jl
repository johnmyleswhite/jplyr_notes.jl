"""
Boolean tuple func checker
"""
@noinline function run_filter(f, tbl, colnames)
    # Extract the columns from the table and create a tuple iterator.
    cols = [tbl[colname] for colname in colnames]
    tpl_itr = zip(cols...)

    # Pre-allocate the table's new column.
    indices = Array(Int, 0)

    # Fill the new column in row-by-row.
    find_indices!(indices, f, tpl_itr)

    # Return the output
    return indices
end
