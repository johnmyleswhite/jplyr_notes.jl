module TestBuildAnonTupleFunc
    using Base.Test
    import TBL

    @testset "build_anon_func" begin
        anon_func1_expr, symbols = TBL.build_anon_func(:(a + b))
        anon_func1 = eval(anon_func1_expr)
        @test anon_func1((1, 2)) === 3
        @test anon_func1((1, 0)) === 1
        @test anon_func1((0, 0)) === 0
    end
end
