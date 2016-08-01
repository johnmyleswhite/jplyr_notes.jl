"""
Recursively descends an expression's AST to find all of the symbols contained
in it. Inserts any unquoted symbols that are found into the set argument,
`s`. Note that this function is not designed to handle assignment-like
expressions: it is intended for application to value expressions only.

Arguments:

* s::Set{Symbol}: A set of symbols that will be mutated whenever any new
    symbols are found.
* e::Any: An expression-like object that will be descended through to find new
    symbols.

Returns:

* Void: These function is used exclusively to mutate the argument `s`.
"""
function find_symbols!(s::Set{Symbol}, e::Any)::Void
    if isa(e, Expr)
        # NOTE: Do not descend when e.head == :quote
        if e.head == :call
            # Ignore e.args[1], which specifies a function name that won't
            # ever need to be resolved into one of the table's columns.
            for i in 2:length(e.args)
                find_symbols!(s, e.args[i])
            end
        elseif e.head in (:(||), :(&&))
            for i in 1:length(e.args)
                find_symbols!(s, e.args[i])
            end
        end
        return
    elseif isa(e, Symbol)
        push!(s, e)
        return
    else
        # NOTE: Do not descend when e is a QuoteNode.
        return
    end
end

"""
Recursively descends an expression's AST to find all of the symbols contained
in it. Returns all found symbols in a `Set{Symbol}` object.

Arguments:

* e::Any: An expression-like object that will be descended through to find new
    symbols.

Returns:

* s::Set{Symbol}: A set containing all of the symbols found by descending
    through the expression-like object's AST.
"""
function find_symbols(e)::Set{Symbol}
    s = Set{Symbol}()
    find_symbols!(s, e)
    return s
end
