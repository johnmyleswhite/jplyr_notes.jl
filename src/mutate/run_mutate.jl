"""
Given a table as a dictionary of NullableVector objects, an ordered list of
column names, and a tuple-to-scalar function, create a tuple iterator by
zipping by the columns in the indicated order, then allocate a NullableArray
into which to store the results. Use type-inference to try to make this
allocation cheap. Then fill in each of the elements of the output by calling
`apply_mutate_func!`.
"""
@noinline function run_mutate(f, tbl, colnames)
    # Determine the length of the output right at the start.
    n = length(colnames) == 0 ? 0 : length(tbl[colnames[1]])

    # Extract the columns from the table and create a tuple iterator.
    cols = [tbl[colname] for colname in colnames]
    if length(cols) == 0
        tpl_itr = (() for _ in 1:n)
    else
        tpl_itr = zip(cols...)
    end

    T = determine_output_type(f, cols)

    # Branch here on non-concrete types on a semantically correct path.
    if !isleaftype(T)
        # TODO: Make this a real code path based on the type-inference
        # independent map implementation in Base. Don't just allocate an Any
        # output.
        @printf(
            STDERR,
            "WARNING: Non-concrete type inferred for tuple-to-scalar function: %s\n",
            T,
        )
        T = Any
    end

    # Pre-allocate the table's new column.
    output = NullableArray(T, n)

    # Fill the new column in row-by-row.
    apply_mutate_func!(output, f, tpl_itr)

    # Return the output
    return output
end
