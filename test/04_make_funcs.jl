module TestMakeFuncs
    using Base.Test
    import TBL: @mutate, Table
    import NullableArrays: NullableArray

    tbl = Table(
        a = convert(NullableArray, [1, 2, 3]),
        b = convert(NullableArray, [4, 5, 6]),
        c = convert(NullableArray, [7.0, 8.0, 9.0]),
    )

    tbl = @mutate(tbl, d = a)
    @test haskey(tbl.symbol_to_index, :d)
    @test isa(tbl[:d], NullableArray{Int, 1})
    @test length(tbl[:d]) === 3
    for i in 1:3
        @test tbl[:d][i] === tbl[:a][i]
    end

    tbl = @mutate(tbl, d = a + b * c)
    @test haskey(tbl.symbol_to_index, :d)
    @test isa(tbl[:d], NullableArray{Float64, 1})
    @test length(tbl[:d]) === 3
    for i in 1:3
        @test tbl[:d][i] === Nullable(
            get(tbl[:a][i]) + get(tbl[:b][i]) * get(tbl[:c][i])
        )
    end

    tbl = @mutate(tbl, d = a + b, e = b + c)
    @test haskey(tbl.symbol_to_index, :d)
    @test isa(tbl[:d], NullableArray{Int, 1})
    @test length(tbl[:d]) === 3
    for i in 1:3
        @test tbl[:d][i] === Nullable(
            get(tbl[:a][i]) + get(tbl[:b][i])
        )
    end

    @test haskey(tbl.symbol_to_index, :e)
    @test isa(tbl[:e], NullableArray{Float64, 1})
    @test length(tbl[:e]) === 3
    for i in 1:3
        @test tbl[:e][i] === Nullable(
            get(tbl[:b][i]) + get(tbl[:c][i])
        )
    end

    tbl = @mutate(tbl, d = a + b, e = b + c, f = a + c)
    @test haskey(tbl.symbol_to_index, :d)
    @test isa(tbl[:d], NullableArray{Int, 1})
    @test length(tbl[:d]) === 3
    for i in 1:3
        @test tbl[:d][i] === Nullable(
            get(tbl[:a][i]) + get(tbl[:b][i])
        )
    end

    @test haskey(tbl.symbol_to_index, :e)
    @test isa(tbl[:e], NullableArray{Float64, 1})
    @test length(tbl[:e]) === 3
    for i in 1:3
        @test tbl[:e][i] === Nullable(
            get(tbl[:b][i]) + get(tbl[:c][i])
        )
    end

    @test haskey(tbl.symbol_to_index, :f)
    @test isa(tbl[:f], NullableArray{Float64, 1})
    @test length(tbl[:f]) === 3
    for i in 1:3
        @test tbl[:f][i] === Nullable(
            get(tbl[:a][i]) + get(tbl[:c][i])
        )
    end

    tbl = @mutate(tbl, d = a + b^2 + sqrt(c) * digamma(c))
end
