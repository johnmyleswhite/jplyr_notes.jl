import TBL: Table, @mutate
import NullableArrays: NullableArray

function array_func(a, b, c, n)
    tmp = Array(Float64, n)
    for i in 1:n
        tmp[i] = digamma(exp(a[i] + b[i] * sqrt(c[i])))
    end
    return (
        copy(a),
        copy(b),
        copy(c),
        tmp,
    )
end

function masked_array_func(a, b, c, m_a, m_b, m_c, n)
    tmp = Array(Float64, n)
    m_tmp = Array(Bool, n)
    for i in 1:n
        if m_a[i] || m_b[i] || m_c[i]
            m_tmp[i] = true
        else
            m_tmp[i] = false
            tmp[i] = digamma(exp(a[i] + b[i] * sqrt(c[i])))
        end
    end
    return (
        copy(a),
        copy(b),
        copy(c),
        copy(m_a),
        copy(m_b),
        copy(m_c),
        tmp,
        m_tmp,
    )
end

function table_versus_array(n, n_reps = 10)
    a, b, c = rand(n), rand(n), rand(n)
    m_a, m_b, m_c = fill(false, n), fill(false, n), fill(false, n)

    tbl = Table(
        a = NullableArray(a, m_a),
        b = NullableArray(a, m_b),
        c = NullableArray(a, m_c),
    )

    t_table = Array(Float64, n_reps)
    @mutate(tbl, d = a + b * sqrt(c))
    for rep in 1:n_reps
        t_table[rep] = @elapsed(
            @mutate(tbl, d = digamma(exp(a + b * sqrt(c))))
        )
    end

    t_array = Array(Float64, n_reps)
    array_func(a, b, c, n)
    for rep in 1:n_reps
        t_array[rep] = @elapsed(array_func(a, b, c, n))
    end

    t_masked_array = Array(Float64, n_reps)
    masked_array_func(a, b, c, m_a, m_b, m_c, n)
    for rep in 1:n_reps
        t_masked_array[rep] = @elapsed(
            masked_array_func(a, b, c, m_a, m_b, m_c, n)
        )
    end

    return (
        minimum(t_table),
        minimum(t_array),
        minimum(t_table) / minimum(t_array),
        minimum(t_masked_array) / minimum(t_array),
    )
end

ns = (
    10,
    25,
    50,
    100,
    250,
    500,
    1_000,
    2_500,
    5_000,
    10_000,
    25_000,
    50_000,
    100_000,
    250_000,
    500_000,
    1_000_000,
    2_500_000,
    5_000_000,
    10_000_000,
    25_000_000,
)

for n in ns
    m_table, m_array, r1, r2 = table_versus_array(n, 10)
    @printf(
        "%16d\t%.6f\t%.6f\t%.6f\t%.6f\n",
        n,
        m_table,
        m_array,
        r1,
        r2,
    )
end
