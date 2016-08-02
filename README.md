# Introduction

This repo contains a WIP proof-of-concept implementation of eagerly
evaluating expressions against tabular data after applying automatic
lifting to handle null values. It is not ready for use by anyone who is
not planning on making development of this library their main priority.

The API is in flux and it is not yet optimized for performance. Its sole
purpose is to demonstrate the viability of introducing a strong
abstraction barrier between the internals of an in-memory tabular data
store and the outward-facing API.

In particular, the API is designed to be defined in terms of "as if"
operations. The library behaves as if it were evaluating expressions
against a source of named tuples. But the library will be free to switch
internals as it sees fit.

# Examples

The core API is defined in terms of a `Table` type, which makes no
promises about internal representations and has a highly restricted, but
highly expressive, API. This `Table` type's API is defined by a few basic
operations:

* `@select`
* `@mutate`
* `@filter`
* `@summarize`
* `@group_by`

To show off this functionality, let's first import it:

```jl
julia> import TBL: Table, @select, @mutate, @filter, @summarize, @group_by

julia> import NullableArrays: NullableArray
```

Then we'll create a basic `Table` object to operate on.

```jl
julia> tbl = Table(
           a = NullableArray([1, 2, 3]),
           b = NullableArray([4, 5, 6]),
           c = NullableArray([7.0, 8.0, 9.0]),
       )
3×3 TBL.Table
│ Row │ a │ b │ c   │
├─────┼───┼───┼─────┤
│ 1   │ 1 │ 4 │ 7.0 │
│ 2   │ 2 │ 5 │ 8.0 │
│ 3   │ 3 │ 6 │ 9.0 │
```

Given a table with many columns, we must select a subset using the
`@select` macro:

```jl
julia> @select(tbl, a, b)
3×2 TBL.Table
│ Row │ a │ b │
├─────┼───┼───┤
│ 1   │ 1 │ 4 │
│ 2   │ 2 │ 5 │
│ 3   │ 3 │ 6 │
```

To create a new table with modified column and/or new columns, use the
`@mutate` macro:

```jl
julia> @mutate(tbl, d = a + b * sqrt(c), e = digamma(d)^2)
3×5 TBL.Table
│ Row │ a │ b │ c   │ d       │ e       │
├─────┼───┼───┼─────┼─────────┼─────────┤
│ 1   │ 1 │ 4 │ 7.0 │ 11.583  │ 5.78764 │
│ 2   │ 2 │ 5 │ 8.0 │ 16.1421 │ 7.56326 │
│ 3   │ 3 │ 6 │ 9.0 │ 21.0    │ 9.12357 │
```

To select a subset of rows satisfying a predicate, use the `@filter`
macro:

```jl
julia> @filter(tbl, a > 1)
2×3 TBL.Table
│ Row │ a │ b │ c   │
├─────┼───┼───┼─────┤
│ 1   │ 2 │ 5 │ 8.0 │
│ 2   │ 3 │ 6 │ 9.0 │
```

To compute an aggregate function over all rows of a table, use the
`@summarize` macro:

```jl
julia> @summarize(tbl, m = mean(a), s = std(a))
1×2 TBL.Table
│ Row │ m   │ s   │
├─────┼─────┼─────┤
│ 1   │ 2.0 │ 1.0 │
```

For now we implement a group-by operation, but it can't be used
downstream and is effectively a no-op until future work is completed:

```jl
julia> @group_by(tbl, a)
"GroupedTable\n"3×3 TBL.Table
│ Row │ a │ b │ c   │
├─────┼───┼───┼─────┤
│ 1   │ 1 │ 4 │ 7.0 │
│ 2   │ 2 │ 5 │ 8.0 │
│ 3   │ 3 │ 6 │ 9.0 │
```

# More Complex Examples

Sometimes you wish to evaluate expressions that refer to variables not
contained in your tabular data store, but in the local scope. To do this,
prefix variable names with a colon. This allows us to define functions that
create dynamic queries given their arguments:

```jl
julia> foo(tbl, x) = @mutate(tbl, d = a + rand() + :x)
foo (generic function with 1 method)

julia> foo(tbl, 1)
3×4 TBL.Table
│ Row │ a │ b │ c   │ d       │
├─────┼───┼───┼─────┼─────────┤
│ 1   │ 1 │ 4 │ 7.0 │ 2.2906  │
│ 2   │ 2 │ 5 │ 8.0 │ 3.93915 │
│ 3   │ 3 │ 6 │ 9.0 │ 4.71653 │

julia> foo(tbl, 10)
3×4 TBL.Table
│ Row │ a │ b │ c   │ d       │
├─────┼───┼───┼─────┼─────────┤
│ 1   │ 1 │ 4 │ 7.0 │ 11.0233 │
│ 2   │ 2 │ 5 │ 8.0 │ 12.776  │
│ 3   │ 3 │ 6 │ 9.0 │ 13.2222 │
```

The access to variables in the local scope even allows one to align external
arrays with a tabular data store that makes no guarantees that the rows are
stored in any specific order. To make use of them, simply insert numeric
indices for the rows into the table as a new column and refer to them in
an expression:

```jl
julia> indexed_tbl = Table(i = NullableArray([1, 2, 3]))
3×1 TBL.Table
│ Row │ i │
├─────┼───┤
│ 1   │ 1 │
│ 2   │ 2 │
│ 3   │ 3 │

julia> function insert_local_array(tbl)
           x = [e, π, γ]
           return @mutate(tbl, x = getindex(:x, i))
           return tbl2
       end
insert_local_array (generic function with 1 method)

julia> insert_local_array(indexed_tbl)
3×2 TBL.Table
│ Row │ i │ x        │
├─────┼───┼──────────┤
│ 1   │ 1 │ 2.71828  │
│ 2   │ 2 │ 3.14159  │
│ 3   │ 3 │ 0.577216 │
```

# Caveats

(1) At the moment, any expression that does not have a concrete return type
raises a warning and uses a very conservative approach that is not
performant. This is particularly problematic when interacting with variables
in the global scope, which are not amenable to type-inference. This will be
improved in the future, but requires some substantive engineering efforts
to copy the type-inference-independent strategy employed by Base Julia for
addressing similar issues in list comprehensions.

(2) There are many expressions that are not analyzed correctly. If you hit
an obscure macro expansion error, this is the likely problem.

(3) Our default strategy for lifting is heavily optimized for performance. But
it will need to be extended to handle some special functions like `isnull(col)`
and `get(col, alternative_value)`. This will take some time to get right.

# Performance

The API proposed here makes heavy use of macro's, syntactic analysis and
anonymous functions. Because of substantial improvements to anonymous functions
in Julia 0.5, it is possible for this approach to produce highly performant
code. But code generation is expensive. As such, for very fast computations,
this approach is often slower than other approaches; it is only as the amount
of computation increases that the costs of compiling custom code are outweighed
by the performance gains.

To see this, consider the benchmark in the `perf/mutate.jl` file. It shows the
following behavior with respect to the number of rows with respect to
operating on arrays using an approach that does not require anonymous functions
or macros:

![Performance Graph](https://github.com/johnmyleswhite/jplyr_notes.jl/blob/master/perf/perf_comparison.png)
