function Base.show(
    io::IO,
    g_tbl::GroupedTable,
    splitchunks::Bool = true,
    rowlabel::Symbol = Symbol("Row"),
    displaysummary::Bool = true
)::Void
    show(io, "GroupedTable\n")
    return show(io, g_tbl.src, splitchunks)
end

function Base.show(g_tbl::GroupedTable, splitchunks::Bool = false)::Void
    show(STDOUT, "GroupedTable\n")
    return show(STDOUT, g_tbl.src, splitchunks)
end
