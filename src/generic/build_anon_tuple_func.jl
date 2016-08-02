"""
TODO: Rename this to make clear that it returns an expression, not a function.
"""
function build_anon_func(e::Any)
    tuple_name = gensym()
    s = find_symbols(e)
    mapping, reverse_mapping = map_symbols(s)
    new_e = replace_symbols(e, mapping, tuple_name)
    return (
        Expr(:->, tuple_name, Expr(:block, new_e)),
        reverse_mapping,
    )
end
