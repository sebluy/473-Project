# add normal registers with nop in between w/o needing forwarding
add $3, $2, $2 # r3 should be 4 at 0 + 5 = 5th clock cycle
nop
nop
add $5, $4, $3 # r5 should be 7 at 3 + 5 = 8th clock cycle
