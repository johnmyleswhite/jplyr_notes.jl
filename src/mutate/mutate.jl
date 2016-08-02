macro mutate(tbl_name, exprs...)
    # We need a name for the variable we'll use in our let block.
    new_tbl_name = gensym()

    # We insert new columns one-by-one. We generate the expressions for the
    # insert operations in a big loop.
    insert_exprs = Any[]
    for e in exprs
        col_name = get_target_name(e)
        core_expr = get_value_expr(e)
        anon_func_expr, reverse_mapping = build_anon_func(core_expr)
        insert_expr = Expr(
            :(=),
            Expr(:ref, esc(new_tbl_name), QuoteNode(col_name)),
            Expr(
                :call,
                :run_mutate,
                anon_func_expr,
                esc(new_tbl_name),
                esc(reverse_mapping),
            ),
        )
        push!(insert_exprs, insert_expr)
    end

    # We end the let block with the name of the new table, so that it becomes
    # the value of the let block.
    push!(insert_exprs, esc(new_tbl_name))

    # Create a block expression using all of its inner expressions.
    insert_block_expr = Expr(:block, insert_exprs...)

    # Create a let-block expression.
    let_expr = Expr(
        :let,
        insert_block_expr,
        Expr(:(=), esc(new_tbl_name), Expr(:call, :copy, esc(tbl_name))),
    )

    return let_expr
end
