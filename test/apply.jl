using TBL
using NullableArrays

f = tpl -> tpl[1] + tpl[2] * tpl[3]
tbl = Dict(
    :a => convert(NullableArray, [1, 2, 3]),
    :b => convert(NullableArray, [4, 5, 6]),
    :c => convert(NullableArray, [7.0, 8.0, 9.0]),
)
colnames = [:a, :b, :c]
new_col = TBL._apply_tuple_func(f, tbl, colnames)

x, y, z = randn(1_000_000), randn(1_000_000), randn(1_000_000)

f = tpl -> tpl[1] + tpl[2] * tpl[3]
tbl = Dict(
    :a => convert(NullableArray, x),
    :b => convert(NullableArray, y),
    :c => convert(NullableArray, z),
)
colnames = [:a, :b, :c]
@time new_col = TBL._apply_tuple_func(f, tbl, colnames)
@time new_col = TBL._apply_tuple_func(f, tbl, colnames)

# Baseline
function baseline(x, y, z)
    n = length(x)
    res, mask = Array(Float64, n), Array(Bool, n)
    for i in 1:n
        res[i] = x[i] + y[i] * z[i]
    end
    return res, mask
end

@time baseline(x, y, z)
@time baseline(x, y, z)

f = tpl -> tpl[1] + tpl[2] * tpl[3]
tbl = Dict(
    :a => NullableArray([1, 2, 3], [false, true, false]),
    :b => NullableArray([4, 5, 6], [false, true, false]),
    :c => NullableArray([7.0, 8.0, 9.0], [false, true, false]),
)
colnames = [:a, :b, :c]
@time new_col = TBL._apply_tuple_func(f, tbl, colnames)
@time new_col = TBL._apply_tuple_func(f, tbl, colnames)
