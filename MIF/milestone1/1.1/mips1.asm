# add normal registers with nop in between w/o needing forwarding
add $3, $2, $2 # r3 should be 4 at 0 + 4 = 4th clock cycle
nop
nop
add $5, $4, $3 # r5 should be 7 at 4 + 4 = 8th clock cycle