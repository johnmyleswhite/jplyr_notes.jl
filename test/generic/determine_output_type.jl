module TestDetermineOutputType
    using Base.Test
    import TBL
    import TBL: Table
    import NullableArrays: NullableArray

    x = NullableArray([1, 2, 3])
    y = NullableArray([4, 5, 6])
    z = NullableArray([7.0, 8.0, 9.0])

    tbl = Table(
        a = x,
        b = y,
        c = z,
    )

    @testset "determine_output_type" begin
        anon_func1_expr, colnames = TBL.build_anon_func(:(a + b))
        anon_func1 = eval(anon_func1_expr)
        cols = [tbl[col] for col in  colnames]
        T = TBL.determine_output_type(anon_func1, cols)
        @test isa(T, DataType)
        @test T === Int64
    end
end
