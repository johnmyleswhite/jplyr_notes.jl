A demo of eager evaluation of arbitrary functions over tabular data.

```
import TBL: @mutate
import NullableArrays: NullableArray
import Distributions

tbl = Dict(
    :a => convert(NullableArray, [1, 2, 3]),
    :b => convert(NullableArray, [4, 5, 6]),
    :c => convert(NullableArray, [7.0, 8.0, 9.0]),
)

@mutate(
    tbl,
    d = a + b * sqrt(c),
    e = digamma(d)^2
)
```

At the moment, any expression that does not have a concrete return type
throws an error. So the following example won't work yet:

```
@mutate(
    tbl,
    d = a + b * sqrt(c),
    e = quantile(Normal(0, 1), a)
)
```
