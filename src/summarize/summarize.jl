macro summarize(tbl_name, exprs...)
    pair_exprs = Any[]
    for e in exprs
        col_name = get_target_name(e)
        # Extract the very first layer, which is the summarization function.
        new_e = e.args[2]
        @assert new_e.head == :call
        g_name = new_e.args[1]
        core_expr = new_e.args[2]
        anon_func_expr, reverse_mapping = build_anon_func(core_expr)
        scalar_expr = Expr(
            :call,
            :_summarize_tuple_func,
            anon_func_expr,
            esc(g_name),
            esc(tbl_name),
            esc(reverse_mapping),
        )
        col_expr = Expr(
            :call,
            :NullableArray,
            Expr(:vect, scalar_expr)
        )
        pair_expr = Expr(:kw, col_name, col_expr)
        push!(pair_exprs, pair_expr)
    end
    return Expr(
        :call,
        :Table,
        pair_exprs...,
    )
end
