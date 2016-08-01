module TestTableConstructors
    using Base.Test
    import TBL: Table
    import NullableArrays: NullableArray, NullableVector

    x = NullableArray([1, 2, 3])
    y = NullableArray([4, 5, 6])
    z = NullableArray([7.0, 8.0, 9.0])

    tbl = Table(
        a = x,
        b = y,
        c = z,
    )

    @testset "Table constructors" begin
        @test isa(tbl, Table)
        @test tbl[:a] === x
        @test tbl[:b] === y
        @test tbl[:c] === z
    end
end
