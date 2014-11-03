.text	#Code Section
main:
li $1 -30 # @ cycle 5 r1 = -30 = 0xffffffe2
li $2, 56 # @ cycle 6 r2 = 56 = 0x38
add $3, $2, $1 # @ cycle 7 r3 = 26 = 0x1a
sub $3, $2, $1 # @ cycle 8 r3 = 86 = 0x56
addu $3, $2, $1 # @ cycle 9 r3 = 26 = 0x1a
subu $3, $2, $1 # @ cycle 10 r3 = 86 = 0x56
and $3, $2, $1 # @ cycle 11 r3 = 32 = 0x20
or $3, $2, $1 # @ cycle 12 r3 = -6 = 0xfffffffa
nor $3, $2, $1 # @ cycle 13 r3 = 5 = 0x5
slt $3, $2, $1 # @ cycle 14 r3 = 0 = 0x0
slt $3, $1, $2 # @ cycle 15 r3 = 1 = 0x1
sll $3, $2, 1 # @ cycle 16 r3 = 112 = 0x70
srl $3, $2, 1 # @ cycle 17 r3 = 28 = 0x1c
sra $3, $2, 3 # @ cycle 18 r3 = 7 = 0x7
jr $2 # @ cycle 14 PC = 56 = 0x38 <- infinite loop
nop
nop
nop
nop
nop
