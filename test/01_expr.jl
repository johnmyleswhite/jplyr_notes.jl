module TestExpr
    using Base.Test
    import TBL

    function test_expr_funcs(e, true_col_name, true_core_expr, true_symbols)
        col_name = TBL._get_column_name(e)
        @test col_name == true_col_name

        core_expr = TBL._get_core_expr(e)
        @test core_expr == true_core_expr

        found_symbols = TBL._find_symbols(core_expr)
        mapping, reverse_mapping = TBL._map_symbols(found_symbols)
        @test length(found_symbols) == length(true_symbols)
        for symbol in true_symbols
            @test symbol in found_symbols
        end
        for (i, symbol) in enumerate(found_symbols)
            @test mapping[symbol] == i
            @test reverse_mapping[i] == symbol
        end

        # TODO: Test replace symbols more effectively.
        new_core_expr = TBL._replace_symbols(core_expr, mapping, :tpl)

        return
    end

    test_expr_funcs(
        :(a = b),
        :a,
        :b,
        (:b, ),
    )

    test_expr_funcs(
        :(a = b + c),
        :a,
        :(b + c),
        (:b, :c),
    )

    test_expr_funcs(
        :(a = b + c * d),
        :a,
        :(b + c * d),
        (:b, :c, :d),
    )

    test_expr_funcs(
        :(a = b > c / sqrt(d)),
        :a,
        :(b > c / sqrt(d)),
        (:b, :c, :d),
    )

    test_expr_funcs(
        :(a = b + log(c, 10) >= c^exp(d + e)),
        :a,
        :(b + log(c, 10) >= c^exp(d + e)),
        (:b, :c, :d, :e),
    )
end
