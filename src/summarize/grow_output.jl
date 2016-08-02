"""
Grow non-null values.
"""
@noinline function _grow_nonnull_output!(output, f, tpl_itr)
    for (i, tpl) in enumerate(tpl_itr)
        # Automatically lift the function f here.
        if !hasnulls(tpl)
            push!(output, f(map(unwrap, tpl)))
        end
    end
    return
end
