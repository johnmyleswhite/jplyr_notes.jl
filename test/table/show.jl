module TestTableShow
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

    io = IOBuffer()
    show(io, tbl)
    s = takebuf_string(io)

    @testset "Table I/O" begin
        @test s == "3×3 TBL.Table\n│ Row │ a │ b │ c   │\n├─────┼───┼───┼─────┤\n│ 1   │ 1 │ 4 │ 7.0 │\n│ 2   │ 2 │ 5 │ 8.0 │\n│ 3   │ 3 │ 6 │ 9.0 │"
    end
end
