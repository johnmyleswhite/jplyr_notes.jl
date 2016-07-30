# TODO: All functions here assume that they're given a keyword argument
# expression as found in the second argument of @foo(df, a = b + c). This
# should be checked explicitly.

# @select(tbl, d = a + b)
# @select(tbl, e = a + b * c)

# TODO: Make this a function of tuples to avoid splatting
# Go through expression and replace everything with tuple indices
# gensym() a name like tpl
# Then map a = b + c
# to tpl -> tpl[1] + tpl[2]

# Then extract columns from table
# Then place them all in a zip iterator that generates tuples
# First pass, extract new column name

# Assume that
#  * tpl[1] is an element of tbl[:a]
#  * tpl[2] is an element of tbl[:b]
#  * tpl[3] is an element of tbl[:c]
#
# colnames encodes this ordering

# TODO:
# Translate @mutate(tbl, d = a + b * c) into a tuple function definition
# that passes the ordered symbols as `colnames` to generate a new column
# then inserts that into a copy of `tbl` with a new column called `:d`.

---

# e = :(a = b + c)
# core_e = get_core_expr(e)
# find_symbols!(s, core_e)
# build_anon_func(core_e)

d = Dict(:a => randn(100), :b => randn(100), :c => randn(100))
@run_func(d, d = a + b * c)
-> apply_tuple_func(d, mappings, tpl -> tpl[1] + tpl[2] * tpl[3])

x = Array(Tuple{Float64, Float64}, 1_000_000)
for i in 1:length(x)
    x[i] = randn(Float64), randn(Float64)
end
@foo(x, a = b + c)
macroexpand(quote @foo(x, a = b + c) end)

tmp_e = build_anon_func(get_core_expr(e))
