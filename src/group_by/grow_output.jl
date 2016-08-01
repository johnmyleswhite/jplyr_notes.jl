"""
Grow a group-by matching.
"""
@noinline function _grow_indices!(indices, f, tpl_itr)
    for (i, tpl) in enumerate(tpl_itr)
        # We only include positive results,
        # which do not include NULL as predicate value.
        if hasnulls(tpl)
            index = Nullable{Union{}}()
        else
            # TODO: Make this whole thing type-stable, possibly by
            # separting out nulls completely.
            index = f(map(unwrap, tpl))
        end

        if haskey(indices, index)
            push!(indices[index], i)
        else
            indices[index] = Int[i]
        end
    end
    return
end
