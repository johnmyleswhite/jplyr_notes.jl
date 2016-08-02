module TestGroupedTableShow
    using Base.Test
    import TBL
    import TBL: Table
    import NullableArrays: NullableArray, NullableVector

    columns = NullableVector[
        NullableArray([1, 2, 3]),
        NullableArray([4, 5, 6]),
        NullableArray([7.0, 8.0, 9.0]),
    ]
    index_to_symbol = Symbol[:a, :b, :c]
    symbol_to_index = Dict{Symbol, Int}(:a => 1, :b => 2, :c => 3)

    tbl = Table(columns, index_to_symbol, symbol_to_index)
    indices = Dict(false => [1], true => [2, 3])
    g_tbl = TBL.GroupedTable(tbl, indices)

    io = IOBuffer()
    show(io, g_tbl)
    s = takebuf_string(io)

    @testset "show(io, g_tbl::GroupedTable)" begin
        @test s == "\"GroupedTable\\n\"3×3 TBL.Table\n│ Row │ a │ b │ c   │\n├─────┼───┼───┼─────┤\n│ 1   │ 1 │ 4 │ 7.0 │\n│ 2   │ 2 │ 5 │ 8.0 │\n│ 3   │ 3 │ 6 │ 9.0 │"
    end
end
