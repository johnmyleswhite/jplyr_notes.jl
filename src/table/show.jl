function Base.summary(tbl::Table)::String
    ncols = length(tbl.columns)
    nrows = ncols == 0 ? 0 : length(tbl.columns[1])
    return @sprintf("%d×%d %s", nrows, ncols, typeof(tbl))
end

ourshowcompact(io::IO, x::Any)::Void = showcompact(io, x)

ourshowcompact(io::IO, x::AbstractString)::Void = showcompact(io, x)

ourshowcompact(io::IO, x::Symbol)::Void = print(io, x)

let
    local io = IOBuffer(Array(UInt8, 80), true, true)

    global ourstrwidth

    function ourstrwidth(x::Any)::Int
        truncate(io, 0)
        ourshowcompact(io, x)
        return position(io)
    end

    function ourstrwidth(x::String)::Int
        return strwidth(x) + 2
    end

    function ourstrwidth(s::Symbol)::Int
        return convert(
            Int,
            ccall(
                :u8_strwidth,
                Csize_t,
                (Ptr{UInt8}, ),
                Base.unsafe_convert(Ptr{UInt8}, s)
            )
        )
    end
end

function getmaxwidths(
    tbl::Table,
    indices::AbstractVector{Int},
    rowlabel::Symbol,
)::Vector{Int}
    maxwidths = Array(Int, length(tbl.columns) + 1)

    NULL_strwidth = 5
    undef_strwidth = ourstrwidth(Base.undef_ref_str)
    row_maxwidth = isempty(indices) ? 0 : ndigits(maximum(indices))

    for (j, col) in enumerate(tbl.columns)
        name = tbl.index_to_symbol[j]

        # (1) Consider length of column name
        maxwidth = ourstrwidth(name)

        # (2) Consider length of longest entry in that column
        for i in indices
            if col.isnull[i]
                maxwidth = max(maxwidth, NULL_strwidth)
            else
                try
                    maxwidth = max(maxwidth, ourstrwidth(col.values[i]))
                catch
                    maxwidth = max(maxwidth, undef_strwidth)
                end
            end
        end

        # TODO: Consider making this a tuple instead
        maxwidths[j] = maxwidth
    end

    maxwidths[length(tbl.columns) + 1] = max(row_maxwidth, ourstrwidth(rowlabel))

    return maxwidths
end

function getprintedwidth(maxwidths::Vector{Int})::Int
    # Include length of line-initial |
    totalwidth = 1
    for i in 1:length(maxwidths)
        # Include length of field + 2 spaces + trailing |
        totalwidth += maxwidths[i] + 3
    end
    return totalwidth
end

function getchunkbounds(
    maxwidths::Vector{Int},
    splitchunks::Bool,
    availablewidth::Int = displaysize()[2],
)::Vector{Int}
    ncols = length(maxwidths) - 1
    rowmaxwidth = maxwidths[ncols + 1]
    if splitchunks
        chunkbounds = [0]
        # Include 2 spaces + 2 | characters for row/col label
        totalwidth = rowmaxwidth + 4
        for j in 1:ncols
            # Include 2 spaces + | character in per-column character count
            totalwidth += maxwidths[j] + 3
            if totalwidth > availablewidth
                push!(chunkbounds, j - 1)
                totalwidth = rowmaxwidth + 4 + maxwidths[j] + 3
            end
        end
        push!(chunkbounds, ncols)
    else
        chunkbounds = [0, ncols]
    end
    return chunkbounds
end

function showrowindices(
    io::IO,
    tbl::Table,
    rowindices::AbstractVector{Int},
    maxwidths::Vector{Int},
    leftcol::Int,
    rightcol::Int,
)::Void
    rowmaxwidth = maxwidths[end]

    for i in rowindices
        # Print row ID
        @printf io "│ %d" i
        padding = rowmaxwidth - ndigits(i)
        for _ in 1:padding
            write(io, ' ')
        end
        print(io, " │ ")
        # Print DataFrame entry
        for j in leftcol:rightcol
            strlen = 0
            try
                strlen = ourstrwidth(tbl.columns[j][i])
                ourshowcompact(io, tbl.columns[j][i])
            catch
                strlen = ourstrwidth(Base.undef_ref_str)
                ourshowcompact(io, Base.undef_ref_str)
            end
            padding = maxwidths[j] - strlen
            for _ in 1:padding
                write(io, ' ')
            end
            if j == rightcol
                if i == rowindices[end]
                    print(io, " │")
                else
                    print(io, " │\n")
                end
            else
                print(io, " │ ")
            end
        end
    end
    return
end

function showrows(
    io::IO,
    tbl::Table,
    rowindices::AbstractVector{Int},
    maxwidths::Vector{Int},
    splitchunks::Bool = false,
    rowlabel::Symbol = Symbol("Row"),
    displaysummary::Bool = true
)::Void
    ncols = length(tbl.columns)

    if displaysummary
        println(io, summary(tbl))
    end

    if isempty(rowindices)
        return
    end

    rowmaxwidth = maxwidths[ncols + 1]
    chunkbounds = getchunkbounds(maxwidths, splitchunks, displaysize(io)[2])
    nchunks = length(chunkbounds) - 1

    for chunkindex in 1:nchunks
        leftcol = chunkbounds[chunkindex] + 1
        rightcol = chunkbounds[chunkindex + 1]

        # Print column names
        @printf io "│ %s" rowlabel
        padding = rowmaxwidth - ourstrwidth(rowlabel)
        for itr in 1:padding
            write(io, ' ')
        end
        @printf io " │ "
        for j in leftcol:rightcol
            s = tbl.index_to_symbol[j]
            ourshowcompact(io, s)
            padding = maxwidths[j] - ourstrwidth(s)
            for itr in 1:padding
                write(io, ' ')
            end
            if j == rightcol
                print(io, " │\n")
            else
                print(io, " │ ")
            end
        end

        # Print table bounding line
        write(io, '├')
        for itr in 1:(rowmaxwidth + 2)
            write(io, '─')
        end
        write(io, '┼')
        for j in leftcol:rightcol
            for itr in 1:(maxwidths[j] + 2)
                write(io, '─')
            end
            if j < rightcol
                write(io, '┼')
            else
                write(io, '┤')
            end
        end
        write(io, '\n')

        # Print main table body, potentially in two abbreviated sections
        showrowindices(io,
                       tbl,
                       rowindices,
                       maxwidths,
                       leftcol,
                       rightcol)

        # Print newlines to separate chunks
        if chunkindex < nchunks
            print(io, "\n\n")
        end
    end

    return
end

function Base.show(
    io::IO,
    tbl::Table,
    splitchunks::Bool = true,
    rowlabel::Symbol = Symbol("Row"),
    displaysummary::Bool = true
)::Void
    nrows = length(tbl.columns) == 0 ? 0 : length(tbl.columns[1])
    dsize = displaysize(io)
    availableheight = dsize[1] - 5
    nrowssubset = fld(availableheight, 2)
    bound = min(nrowssubset - 1, nrows)
    if nrows <= availableheight
        rowindices = 1:nrows
    else
        rowindices = 1:bound
    end
    maxwidths = getmaxwidths(tbl, rowindices, rowlabel)
    width = getprintedwidth(maxwidths)
    showrows(
        io,
        tbl,
        rowindices,
        maxwidths,
        splitchunks,
        rowlabel,
        displaysummary,
    )
    return
end

function Base.show(tbl::Table, splitchunks::Bool = false)::Void
    return show(STDOUT, tbl, splitchunks)
end
