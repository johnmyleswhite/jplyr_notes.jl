module TestGroupedTableTypeDef
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

    @testset "GroupedTable type definition" begin
        @test isa(g_tbl, TBL.GroupedTable)
        @test g_tbl.src.columns === columns
        @test g_tbl.src.index_to_symbol === index_to_symbol
        @test g_tbl.src.symbol_to_index === symbol_to_index
        @test g_tbl.group_indices === indices
    end
end
