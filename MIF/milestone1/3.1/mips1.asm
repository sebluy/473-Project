# test M/WB forwarding of each register argument
add $1, $0, $0 # r1 = 0 @ cycle 5
nop
add $2, $1, $0 # r2 = 0 @ cycle 7
nop
add $3, $0, $2 # r3 = 0 @ cycle 9
