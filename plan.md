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
