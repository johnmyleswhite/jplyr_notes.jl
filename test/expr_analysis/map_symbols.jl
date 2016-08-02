module TestMapSymbols
    using Base.Test
    import TBL

    include("test_cases.jl")

    function test_mapping(ss)::Void
        mapping, reverse_mapping = TBL.map_symbols(ss)
        for (i, s) in enumerate(ss)
            @test mapping[s] == i
            @test reverse_mapping[i] == s
        end
        return
    end

    @testset "Index a set of symbols" begin
        for test_case in assignment_exprs
            e, target_name, value_expr, s, mapping, alt_value_expr = test_case
            test_mapping(s)
        end
    end
end
