module TestReplaceSymbols
    using Base.Test
    import TBL

    include("test_cases.jl")

    # NOTE: This assumes that the tuple name for the symbol replacement is
    # always `:tpl`. This is currently true in the `test_cases.jl` file, but
    # we should eventually test other tuple names to make sure we haven't
    # overfitted the test cases.
    function test_replace_symbols(
        e::Any,
        s::Set{Symbol},
        mapping::Dict{Symbol, Int},
        alt_e::Any,
    )::Void
        @test TBL.replace_symbols(e, mapping, :tpl) == alt_e
        return
    end

    @testset "Replace a set of symbols in an AST-like object" begin
        for test_case in assignment_exprs
            e, target_name, value_expr, s, mapping, alt_value_expr = test_case
            test_replace_symbols(value_expr, s, mapping, alt_value_expr)
        end
    end
end
