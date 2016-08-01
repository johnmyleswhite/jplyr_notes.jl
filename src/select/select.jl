macro select(tbl, symbols...)
    return Expr(:call, :select, esc(tbl), symbols)
end

function select(tbl, symbols)::Table
    new_tbl = Table()
    for s in symbols
        new_tbl[s] = copy(tbl[s])
    end
    return new_tbl
end
