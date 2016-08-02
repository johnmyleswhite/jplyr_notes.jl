# TODO: Handle multiple expressions
macro group_by(tbl_name, e)
    anon_func_expr, reverse_mapping = build_anon_func(e)
    get_indices_expr = Expr(
        :call,
        :_group_by_tuple_func,
        anon_func_expr,
        esc(tbl_name),
        esc(reverse_mapping),
    )
    grouped_table_expr = Expr(
        :call,
        :GroupedTable,
        esc(tbl_name),
        get_indices_expr,
    )
    return grouped_table_expr
end
