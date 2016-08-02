module TestTableTypeDef
    using Base.Test
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

    @testset "Table type definition" begin
        @test isa(tbl, Table)
        @test tbl.columns === columns
        @test tbl.index_to_symbol === index_to_symbol
        @test tbl.symbol_to_index === symbol_to_index
    end
end
