using TBL
using NullableArrays

tbl = Dict(
    :a => convert(NullableArray, [1, 2, 3]),
    :b => convert(NullableArray, [4, 5, 6]),
    :c => convert(NullableArray, [7.0, 8.0, 9.0]),
)

TBL.@mutate(tbl, d = a + b * c)
