# clear r2
add $2, $0, $0 # r2 should be 0 at 0 + 5 = 5th clock cycle
# test random registers
add $31, $30, $30 # r31 should be 30 + 30 = 60 = 0x3C at 1 + 5 = 6th clock cycle
add $15, $14, $13 # r15 should be 14 + 13 = 27 = 0x1B at 2 + 5 = 7th clock cycle