module TestApply
    using Base.Test
    import TBL
    import NullableArrays: NullableArray

    f = tpl -> tpl[1] + tpl[2] * tpl[3]
    tbl = Dict(
        :a => convert(NullableArray, [1, 2, 3]),
        :b => convert(NullableArray, [4, 5, 6]),
        :c => convert(NullableArray, [7.0, 8.0, 9.0]),
    )
    colnames = [:a, :b, :c]
    new_col = TBL._apply_tuple_func(f, tbl, colnames)
    @test new_col[1] === Nullable(1 + 4 * 7.0)
    @test new_col[2] === Nullable(2 + 5 * 8.0)
    @test new_col[3] === Nullable(3 + 6 * 9.0)

    f = tpl -> tpl[1] + tpl[2] * tpl[3]
    tbl = Dict(
        :a => NullableArray([1, 2, 3], [false, true, false]),
        :b => NullableArray([4, 5, 6], [false, true, false]),
        :c => NullableArray([7.0, 8.0, 9.0], [false, true, false]),
    )
    colnames = [:a, :b, :c]
    new_col = TBL._apply_tuple_func(f, tbl, colnames)
    @test new_col[1] === Nullable(1 + 4 * 7.0)
    @test isa(new_col[2], Nullable{Float64})
    @test isnull(new_col[2])
    @test new_col[3] === Nullable(3 + 6 * 9.0)
end
