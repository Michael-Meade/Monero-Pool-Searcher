require  'xmrpoolsearch'
addr = "8ALdP9yTXenfNjgpm5TrRf7TGoBr8aUKU3kQcu7CLzfVJZYMXTohVb85GrRu7dy8PsTYrcisdG9LdMTmkuPRdZN7CnFsVWB"
# Get Pool

Pools::get_pools(addr)


# Print table
Pools::print_table(addr)


# debug
Pools::print_table(addr, true) 