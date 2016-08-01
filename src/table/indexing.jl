# TODO: Give these function alternative names to make them non-public.
function Base.getindex(tbl::Table, s::Symbol)::NullableVector
    if haskey(tbl.symbol_to_index, s)
        index = tbl.symbol_to_index[s]
        return tbl.columns[index]
    else
        error(@sprintf("Invalid column name: %s", s))
    end
end

function Base.setindex!(tbl::Table, v::NullableVector, s::Symbol)::Void
    if haskey(tbl.symbol_to_index, s)
        index = tbl.symbol_to_index[s]
        tbl.columns[index] = v
    else
        n = length(tbl.columns)
        index = n + 1
        # TODO: Make these three operations atomic.
        push!(tbl.index_to_symbol, s)
        tbl.symbol_to_index[s] = index
        push!(tbl.columns, v)
    end
    return
end
