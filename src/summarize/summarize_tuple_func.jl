"""
Summarize tuple function
"""
@noinline function _summarize_tuple_func(f, g, tbl, colnames)
    # Extract the columns from the table and create a tuple iterator.
    cols = [tbl[colname] for colname in colnames]
    tpl_itr = zip(cols...)

    # Determine the tuple type of the iterator after unwrapping all Nullables.
    #
    # TODO: Handle the possibility of columns that are not NullableArrays here.
    # Better yet, don't handle that possibility and avoid a lot of shanigans
    # elsewhere.
    inner_types = map(x -> eltype(eltype(x)), cols)

    # See if inference knows the return type for the tuple-to-scalar function.
    t = Core.Inference.return_type(f, (Tuple{inner_types...}, ))

    # If there is no method found (or it returns nothing), t === Union{}.
    # if t == Union{}
    #     error("No method found for those types")
    # end

    # Branch here on non-concrete types.
    if !isleaftype(t)
        # TODO: Make this a real code path based on the type-inference
        # independent map implementation in Base.
        @printf("WARNING: Failed to type-infer expression: found %s\n", t)
        t = Any
    end

    # Allocate a temporary column.
    temporary = Array(t, 0)

    # Fill the new column in row-by-row, skipping nulls.
    _grow_nonnull_output!(temporary, f, tpl_itr)

    # Return the summarization function applied to the temporary.
    return g(temporary)
end
