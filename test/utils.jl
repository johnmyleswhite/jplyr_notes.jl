module TestUtils
    using Base.Test
    import TBL
    import NullableArrays: NullableArray, NullableVector

    test_examples = (
        ((1, Nullable{Int}()), true),
        ((1, Nullable(1)), false),
        ((1, 1), false),
    )

    @testset "hasnulls(itr)" begin
        for (itr, truth_value) in test_examples
            @test TBL.hasnulls(itr) === truth_value
        end
    end

    @testset "unwrap(x)" begin
        @test TBL.unwrap(Nullable(1)) === 1
        @test TBL.unwrap(1) === 1
    end
end
