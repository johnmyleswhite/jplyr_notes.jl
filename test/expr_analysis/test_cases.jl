# TODO: Add non-assignment-like expressions as well
# TODO: Rewrite these test cases to escape all non-targetted symbols.

# A test case is a tuple of:
#     * An assignment-like expression.
#     * A target name.
#     * A value expression.
#     * A set of symbols in the value expression.
#     * A preferred mapping between symbols and indices.
#     * A rewrite of the value expression into a tuple-indexing form.

assignment_exprs = (
    (
        :(a = 1),
        :a,
        1,
        Set(Symbol[]),
        Dict{Symbol, Int}(),
        1,
    ),
    (
        :(a = b),
        :a,
        :b,
        Set(Symbol[:b]),
        Dict(:b => 1),
        :(tpl[1]),
    ),
    (
        :(a = rand()),
        :a,
        :(rand()),
        Set(Symbol[]),
        Dict{Symbol, Int}(),
        :(rand()),
    ),
    (
        :(a = b + c),
        :a,
        :(b + c),
        Set(Symbol[:b, :c]),
        Dict(:b => 1, :c => 2),
        :(tpl[1] + tpl[2]),
    ),
    (
        :(a = b + c > c + d),
        :a,
        :(b + c > c + d),
        Set(Symbol[:b, :c, :d]),
        Dict(:b => 1, :c => 2, :d => 3),
        :(tpl[1] + tpl[2] > tpl[2] + tpl[3]),
    ),
    (
        :(a = b == 1 || c == 2),
        :a,
        :(b == 1 || c == 2),
        Set(Symbol[:b, :c]),
        Dict(:b => 1, :c => 2),
        :(tpl[1] == 1 || tpl[2] == 2),
    ),
    (
        :(a = b == 1 && c == 2),
        :a,
        :(b == 1 && c == 2),
        Set(Symbol[:b, :c]),
        Dict(:b => 1, :c => 2),
        :(tpl[1] == 1 && tpl[2] == 2),
    ),
    (
        :(a = b + c * d),
        :a,
        :(b + c * d),
        Set(Symbol[:b, :c, :d]),
        Dict(:b => 1, :c => 2, :d => 3),
        :(tpl[1] + tpl[2] * tpl[3]),
    ),
    (
        :(a = b > c / sqrt(d)),
        :a,
        :(b > c / sqrt(d)),
        Set(Symbol[:b, :c, :d]),
        Dict(:b => 1, :c => 2, :d => 3),
        :(tpl[1] > tpl[2] / sqrt(tpl[3])),
    ),
    (
        :(a = b + log(c, 10) >= c^exp(d + e)),
        :a,
        :(b + log(c, 10) >= c^exp(d + e)),
        Set(Symbol[:b, :c, :d, :e]),
        Dict(:b => 1, :c => 2, :d => 3, :e => 4),
        :(tpl[1] + log(tpl[2], 10) >= tpl[2]^exp(tpl[3] + tpl[4])),
    ),
)
