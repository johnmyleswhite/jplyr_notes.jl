"""
Traverse an AST-like object and replace a fixed set of symbols with
tuple-indexing expressions.

Arguments:

* e::Any: An AST-like object.
* mapping:Dict{Symbol, Int}: A mapping from symbols to numeric indices.
* tuple_name::Symbol: The name of the tuple that will be indexed into.

Returns:

* new_e::Any: A new AST-like object with all symbols replaced with
    tuple-indexing operations.
"""
function replace_symbols(
    e::Any,
    mapping::Dict{Symbol, Int},
    tuple_name::Symbol,
)::Any
    if isa(e, Expr)
        # To ensure purity, we copy any Expr objects rather than mutate them.
        new_e = copy(e)
        if new_e.head == :call
            # Escape the functions being called so they're not sourced from the
            # TBL module.
            # TODO: Restore this line after updating tests to ignore it.
            # new_e.args[1] = esc(new_e.args[1])
            for i in 2:length(new_e.args)
                new_e.args[i] = replace_symbols(
                    new_e.args[i],
                    mapping,
                    tuple_name,
                )
            end
        elseif new_e.head == :quote
            # Replace quoted symbols with raw symbols.
            return esc(new_e.args[1])
        elseif new_e.head in (:(||), :(&&))
            for i in 1:length(new_e.args)
                new_e.args[i] = replace_symbols(
                    new_e.args[i],
                    mapping,
                    tuple_name,
                )
            end
        else
            # TODO: Handle other kinds of Expr heads.
            error(
                @sprintf("Unknown Expr head type %s in %s", new_e.head, new_e)
            )
        end
        return new_e
    elseif isa(e, Symbol)
        # Replace unquoted symbols with tuple indexing expressions.
        return Expr(:ref, tuple_name, mapping[e])
    elseif isa(e, QuoteNode)
        # Replace quoted symbols with raw symbols.
        return e.value
    else
        # Hopefully we have a literal here since we stop going down the AST
        # when we hit this branch.
        return e
    end
    return
end
