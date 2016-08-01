module TestFindSymbols
    using Base.Test
    import TBL

    include("test_cases.jl")

    function test_find_symbols(e::Any, s::Set{Symbol})::Void
        @test TBL.find_symbols(e) == s
        return
    end

    @testset "Find all symbols in AST-like objects" begin
        for test_case in assignment_exprs
            e, target_name, value_expr, s, mapping, alt_value_expr = test_case
            test_find_symbols(value_expr, s)
        end
    end
end
