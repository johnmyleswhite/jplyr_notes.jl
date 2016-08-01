 A demo of eager evaluation of arbitrary functions over tabular data.

```
import TBL: Table, @mutate, @filter, @summarize, @select, @group_by
import NullableArrays: NullableArray
import Distributions: Normal, pdf

tbl = Table(
    a = convert(NullableArray, [1, 2, 3]),
    b = convert(NullableArray, [4, 5, 6]),
    c = convert(NullableArray, [7.0, 8.0, 9.0]),
)

tbl1 = @select(tbl, a, b)

@group_by(tbl, a)
@group_by(tbl, a > 1)

tbl2 = @mutate(
    tbl,
    d = a + b * sqrt(c),
    e = digamma(d)^2
)

tbl = @mutate(tbl, e = 1)

tbl = @mutate(tbl, e = rand())

tbl3 = @filter(tbl2, d > 15)

tbl4 = @summarize(tbl3, m = mean(e), s = std(e))

tbl5 = @summarize(tbl, m = sum(a + b * c))

tbl6 = @mutate(
    tbl,
    d = a + rand(),
    e = digamma(d)^2
)

foo(tbl, x) = @mutate(tbl, d = a + rand() + :x)
foo(tbl, 1)

x = 1
@filter(tbl, a == :x)

@filter(tbl, a > :x)

@filter(tbl, a == 1)
@filter(tbl, a > 1)
@filter(tbl, b == 5)
@filter(tbl, a == 1 || b == 5)

tbl7 = @mutate(
    tbl,
    d = a + b * sqrt(c),
    e = pdf(Normal(0, 1), a)
)

# Even numeric indexing into an ambient array can be made to work, if done
# properly:

tbl = Table(
    i = NullableArray([1, 2, 3]),
)

function inserting_local_array(tbl)
    x = [e, π, γ]
    tbl2 = @mutate(tbl, x = getindex(:x, i))
    # tbl3 = @mutate(tbl, x = :x[i])
    return tbl2
end

tbl2 = inserting_local_array(tbl)
```

At the moment, any expression that does not have a concrete return type
raises a warning and uses a very conservative approach that is not
performant. This is particularly problematic when interacting with variables
in the global scope, which are not amenable to type-inference. This will be
improved in the future, but requires some substantive engineering efforts
to copy the type-inference-independent strategy employed by Base Julia for
addressing similar issues in list comprehensions.
