module TestAssignmentExprOps
    using Base.Test
    import TBL

    include("test_cases.jl")

    function test_assignment_expr_funcs(e, target_name, value_expr)::Void
        @test TBL.get_target_name(e) == target_name
        @test TBL.get_value_expr(e) == value_expr
        return
    end

    @testset "Parse assignment-like expressions" begin
        for test_case in assignment_exprs
            e, target_name, value_expr, s, mapping, alt_value_expr = test_case
            test_assignment_expr_funcs(e, target_name, value_expr)
        end
    end
end
