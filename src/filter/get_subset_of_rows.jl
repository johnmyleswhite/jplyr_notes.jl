function partial_copy!(
    new_col::NullableVector,
    col::NullableVector,
    indices::Vector{Int},
)::Void
    for (new_ind, old_ind) in enumerate(indices)
        if col.isnull[old_ind]
            new_col.isnull[new_ind] = true
        else
            new_col.isnull[new_ind] = false
            new_col.values[new_ind] = col.values[old_ind]
        end
    end
    return
end

function get_subset_of_rows(tbl, indices)::Table
    n = length(indices)
    new_tbl = Table()
    for (j, col) in enumerate(tbl.columns)
        col_name = tbl.index_to_symbol[j]
        new_col = NullableArray(eltype(eltype(col)), n)
        partial_copy!(new_col, col, indices)
        new_tbl[col_name] = new_col
    end
    return new_tbl
end
