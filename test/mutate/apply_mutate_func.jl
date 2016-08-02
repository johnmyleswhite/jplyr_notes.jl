module TestApplyMutateFunc
    using Base.Test
    import TBL
    import TBL: Table
    import NullableArrays: NullableArray

    @testset "apply_mutate_func!" begin
        x = NullableArray([1, 2, 3])
        y = NullableArray([4, 5, 6])
        z = NullableArray([7.0, 8.0, 9.0])

        tbl = Table(
            a = x,
            b = y,
            c = z,
        )

        f = tpl -> tpl[1] + tpl[2] * sqrt(tpl[3])
        output = NullableArray(Float64, 3)
        tuple_iterator = zip(tbl[:a], tbl[:b], tbl[:c])
        TBL.apply_mutate_func!(output, f, tuple_iterator)
        @test output[1] === Nullable(11.583005244258363)
        @test output[2] === Nullable(16.14213562373095)
        @test output[3] === Nullable(21.0)

        f = tpl -> tpl[1] + tpl[2]
        output = NullableArray(Int, 4)
        tuple_iterator = (
            (1, 1),
            (2, 2),
            (3, Nullable(3)),
            (4, Nullable{Int}()),
        )
        TBL.apply_mutate_func!(output, f, tuple_iterator)
        @test output[1] === Nullable(2)
        @test output[2] === Nullable(4)
        @test output[3] === Nullable(6)
        @test isa(output[4], Nullable{Int})
        @test isnull(output[4])
    end
end
