#
# Correctness Tests
#

fatalerrors = length(ARGS) > 0 && ARGS[1] == "-f"
quiet = length(ARGS) > 0 && ARGS[1] == "-q"
anyerrors = false

my_tests = (
    "utils.jl",
    "expr_analysis/assignment_expr_ops.jl",
    "expr_analysis/find_symbols.jl",
    "expr_analysis/map_symbols.jl",
    "expr_analysis/replace_symbols.jl",
    "table/type_def.jl",
    "table/constructors.jl",
    "table/copy.jl",
    "table/indexing.jl",
    "table/show.jl",
    "grouped_table/type_def.jl",
    "grouped_table/show.jl",
    "generic/build_anon_tuple_func.jl",
    "generic/determine_output_type.jl",
    "select/select.jl",
    "mutate/apply_mutate_func.jl",
    "mutate/run_mutate.jl",
    "mutate/mutate.jl",
    "filter/filter.jl",
    "filter/find_indices.jl",
    "filter/get_subset_of_rows.jl",
    "filter/run_filter.jl",
    "summarize/grow_output.jl",
    "summarize/summarize_tuple_func.jl",
    "summarize/summarize.jl",
    "group_by/grow_output.jl",
    "group_by/group_by_tuple_func.jl",
    "group_by/group_by.jl",
    # TODO: Remove these vestigial tests.
    "03_apply.jl",
    "04_make_funcs.jl",
)

println("Running tests:")

using Base.Test

@testset "All tests" begin
    for my_test in my_tests
        try
            include(my_test)
            println("\t\033[1m\033[32mPASSED\033[0m: $(my_test)")
        catch e
            anyerrors = true
            println("\t\033[1m\033[31mFAILED\033[0m: $(my_test)")
            if fatalerrors
                rethrow(e)
            elseif !quiet
                showerror(STDOUT, e, backtrace())
                println()
            end
        end
    end
end

if anyerrors
    throw("Tests failed")
end
