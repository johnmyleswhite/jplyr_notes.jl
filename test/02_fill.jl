module TestFill
    using Base.Test
    import TBL
    import NullableArrays: NullableArray

    test_examples = (
        ((1, Nullable{Int}()), true),
        ((1, Nullable(1)), false),
        ((1, 1), false),
    )

    for (itr, truth_value) in test_examples
        @test TBL._hasnulls(itr) === truth_value
    end

    @test TBL._unwrap(Nullable(1)) === 1
    @test TBL._unwrap(1) === 1

    output = NullableArray(Int, 4)
    f = tpl -> tpl[1] + tpl[2]
    tpl_itr = (
        (1, 1),
        (2, 2),
        (3, Nullable(3)),
        (4, Nullable{Int}()),
    )
    TBL._fill_output!(output, f, tpl_itr)
    @test output[1] === Nullable(2)
    @test output[2] === Nullable(4)
    @test output[3] === Nullable(6)
    @test isa(output[4], Nullable{Int})
    @test isnull(output[4])
end
