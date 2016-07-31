function _build_anon_func(e::Union{Symbol, Expr})
    tpl_name = gensym()
    s = _find_symbols(e)
    mapping, reverse_mapping = _map_symbols(s)
    new_e = _replace_symbols(e, mapping, tpl_name)
    return (
        Expr(:->, tpl_name, Expr(:block, Expr(:line, 1), new_e)),
        reverse_mapping,
    )
end

# TODO: Decide whether to provide both @mutate! vs @mutate macros.
macro mutate(tbl_name, exprs...)
    insert_exprs = []
    new_tbl_name = gensym()
    for e in exprs
        col_name = _get_column_name(e)
        core_expr = _get_core_expr(e)
        anon_func_expr, reverse_mapping = _build_anon_func(core_expr)
        insert_expr = Expr(
            :(=),
            Expr(:ref, esc(new_tbl_name), QuoteNode(col_name)),
            Expr(
                :call,
                :_apply_tuple_func,
                anon_func_expr,
                esc(new_tbl_name),
                esc(reverse_mapping),
            ),
        )
        push!(insert_exprs, insert_expr)
    end
    push!(insert_exprs, esc(new_tbl_name))
    insert_block_expr = Expr(:block, insert_exprs...)
    let_expr = Expr(
        :let,
        insert_block_expr,
        Expr(:(=), esc(new_tbl_name), Expr(:call, :copy, esc(tbl_name))),
    )
    return let_expr
end

# Filter
# TODO: Handle multiple expressions.
macro filter(tbl_name, e)
    anon_func_expr, reverse_mapping = _build_anon_func(e)
    get_indices_expr = Expr(
        :call,
        :_boolean_tuple_func,
        anon_func_expr,
        esc(tbl_name),
        esc(reverse_mapping),
    )
    filter_expr = Expr(
        :call,
        :_get_subset,
        esc(tbl_name),
        get_indices_expr,
    )
    return filter_expr
end

macro summarize(tbl_name, exprs...)
    pair_exprs = Any[]
    for e in exprs
        col_name = _get_column_name(e)
        # Extract the very first layer, which is the summarization function.
        new_e = e.args[2]
        @assert new_e.head == :call
        g_name = new_e.args[1]
        core_expr = new_e.args[2]
        anon_func_expr, reverse_mapping = _build_anon_func(core_expr)
        # Upgrade this to a proper Dict{Symbol, NullableVector}
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
        pair_expr = Expr(:(=>), QuoteNode(col_name), col_expr)
        push!(pair_exprs, pair_expr)
    end
    return Expr(
        :call,
        :Dict,
        pair_exprs...,
    )
end
