"""
Given a table as a dictionary of NullableArray objects, an ordered list of
column names, and a tuple-to-scalar function, create a tuple iterator by
zipping by the columns in the indicated order, then allocate a NullableArray
into which to store the results.
"""
@noinline function _apply_tuple_func(f, tbl, colnames)
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
    # This happens if you invoke stuff not in the shared Base scope.
    # if t == Union{}
    #     error("No method found for those types")
    # end

    # Branch here on non-concrete types on a semantically correct path.
    if !isleaftype(t)
        # TODO: Make this a real code path based on the type-inference
        # independent map implementation in Base.
        @printf("WARNING: Failed to type-infer expression: found %s", t)
        t = Any
    end

    # Pre-allocate the table's new column.
    n = length(tbl[colnames[1]])
    output = NullableArray(t, n)

    # Fill the new column in row-by-row.
    _fill_output!(output, f, tpl_itr)

    # Return the output
    return output
end

"""
Boolean tuple func checker
"""
@noinline function _boolean_tuple_func(f, tbl, colnames)
    # Extract the columns from the table and create a tuple iterator.
    cols = [tbl[colname] for colname in colnames]
    tpl_itr = zip(cols...)

    # Pre-allocate the table's new column.
    n = length(tbl[colnames[1]])
    indices = Array(Int, 0)

    # Fill the new column in row-by-row.
    _grow_output!(indices, f, tpl_itr)

    # Return the output
    return indices
end

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
        @printf("WARNING: Failed to type-infer expression: found %s", t)
        t = Any
    end

    # Allocate a temporary column.
    temporary = Array(t, 0)

    # Fill the new column in row-by-row, skipping nulls.
    _grow_nonnull_output!(temporary, f, tpl_itr)

    # Return the summarization function applied to the temporary.
    return g(temporary)
end
