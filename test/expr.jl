include("src/expr.jl")

using Base.Test

function test_expr_funcs(col_name, core_expr, all_symbols)
    @test get_column_name(e) == col_name

    @test get_core_expr(e) == core_expr

    found_symbols = Set{Symbol}()
    find_symbols!(found_symbols, get_core_expr(e))
    for symbol in all_symbols
        @test symbol in found_symbols
    end
    @test length(found_symbols) == length(all_symbols)

    return
end

e = :(a = b + c)
test_expr_funcs(:a, :(b + c), (:b, :c))

e = :(a = b + c * d)
test_expr_funcs(:a, :(b + c * d), (:b, :c, :d))

e = :(a = b > c / sqrt(d))
test_expr_funcs(:a, :(b > c / sqrt(d)), (:b, :c, :d))

e = :(a = b + log(c, 10) >= c^exp(d + e))
test_expr_funcs(:a, :(b + log(c, 10) >= c^exp(d + e)), (:b, :c, :d, :e))

# mapping = Dict(:b => :(tpl[1]), :c => :(tpl[2]))
# replace_symbols!(mapping, core_e)

e = :(a = b + c)
s = find_symbols(get_core_expr(e))
mapping = map_symbols(s)


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
