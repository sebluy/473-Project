# test single register forwarding  from EX/MEM to ALU
add $1, $0, $0 # r1 = 0 @ cycle 5
add $2, $1, $3 # r2 = 3 @ cycle 6
add $3, $3, $2 # r3 = 3 + 3 = 6 @ cycle 7
