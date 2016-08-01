# TODO: Handle multiple expressions.
macro filter(tbl_name, e)
    anon_func_expr, reverse_mapping = build_anon_func(e)
    get_indices_expr = Expr(
        :call,
        :run_filter,
        anon_func_expr,
        esc(tbl_name),
        esc(reverse_mapping),
    )
    filter_expr = Expr(
        :call,
        :get_subset_of_rows,
        esc(tbl_name),
        get_indices_expr,
    )
    return filter_expr
end
