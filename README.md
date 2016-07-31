 A demo of eager evaluation of arbitrary functions over tabular data.

```
import TBL: @mutate, @filter, @summarize
import NullableArrays: NullableArray
import Distributions: Normal, pdf

tbl = Dict(
    :a => convert(NullableArray, [1, 2, 3]),
    :b => convert(NullableArray, [4, 5, 6]),
    :c => convert(NullableArray, [7.0, 8.0, 9.0]),
)

tbl2 = @mutate(
    tbl,
    d = a + b * sqrt(c),
    e = digamma(d)^2
)

tbl3 = @filter(tbl2, d > 15)

tbl4 = @summarize(tbl3, m = mean(e), s = std(e))

@summarize(tbl, m = sum(a + b * c))

@mutate(
    tbl,
    d = a + rand(),
    e = digamma(d)^2
)

function foo(tbl, x)
    @mutate(tbl, d = a + rand() + :x)
end
foo(tbl, 1)

x = 1
@filter(tbl, a == :x)

@filter(tbl, a > :x)

@filter(tbl, a == 1)
@filter(tbl, a > 1)
@filter(tbl, b == 5)
@filter(tbl, a == 1 || b == 5)
```

At the moment, any expression that does not have a concrete return type
throws an error. So the following example won't work yet:

```
@mutate(
    tbl,
    d = a + b * sqrt(c),
    e = pdf(Normal(0, 1), c)
)
```
