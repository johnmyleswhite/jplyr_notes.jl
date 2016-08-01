"""
Find all of row indices satisfying a predicate function, `f`.
"""
@noinline function find_indices!(indices, f, tuple_iterator)
    for (i, tpl) in enumerate(tuple_iterator)
        # We only include results for which the predicate is true.
        # This means we exclude both NULL and false values.
        if !hasnulls(tpl) && f(map(unwrap, tpl))::Bool
            push!(indices, i)
        end
    end
    return
end
