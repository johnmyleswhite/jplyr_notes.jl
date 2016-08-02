module TBL
    import NullableArrays: NullableArray, NullableVector

    include("utils.jl")

    include("table/type_def.jl")
    include("table/constructors.jl")
    include("table/indexing.jl")
    include("table/copy.jl")
    include("table/show.jl")

    include("grouped_table/type_def.jl")
    include("grouped_table/show.jl")

    include("expr_analysis/assignment_expr_ops.jl")
    include("expr_analysis/find_symbols.jl")
    include("expr_analysis/map_symbols.jl")
    include("expr_analysis/replace_symbols.jl")

    include("generic/build_anon_tuple_func.jl")
    include("generic/determine_output_type.jl")

    include("select/select.jl")

    include("mutate/apply_mutate_func.jl")
    include("mutate/run_mutate.jl")
    include("mutate/mutate.jl")

    include("filter/find_indices.jl")
    include("filter/get_subset_of_rows.jl")
    include("filter/run_filter.jl")
    include("filter/filter.jl")

    include("summarize/grow_output.jl")
    include("summarize/summarize_tuple_func.jl")
    include("summarize/summarize.jl")

    include("group_by/grow_output.jl")
    include("group_by/group_by_tuple_func.jl")
    include("group_by/group_by.jl")
end
