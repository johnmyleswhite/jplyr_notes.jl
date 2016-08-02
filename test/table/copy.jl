module TestTableCopy
    using Base.Test
    import TBL: Table
    import NullableArrays: NullableArray, NullableVector

    x = NullableArray([1, 2, 3])
    y = NullableArray([4, 5, 6])
    z = NullableArray([7.0, 8.0, 9.0])

    tbl1 = Table(
        a = x,
        b = y,
        c = z,
    )

    tbl2 = copy(tbl1)

    @testset "copy(tbl::Table)" begin
        @test isa(tbl1, Table)
        @test tbl1[:a] === x
        @test tbl1[:b] === y
        @test tbl1[:c] === z

        @test isa(tbl2, Table)
        @test !(tbl2[:a] === x)
        @test !(tbl2[:b] === y)
        @test !(tbl2[:c] === z)
    end
end
