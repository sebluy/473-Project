.text	#Code Section
main:
li $1 -30 # @ cycle 5 r1 = -30 = 0xffffffe2
li $2, 56 # @ cycle 6 r2 = 56 = 0x38
add $2, $2, $1 # @ cycle 7 r2 = 26 = 0x1a
sub $2, $1, $2 # @ cycle 8 r2 = -56 = 0xffffffc8
addu $2, $2, $1 # @ cycle 9 r2 = -86 = 0xffffffaa
subu $2, $2, $1 # @ cycle 10 r2 = -56 = 0xffffffc8
and $2, $2, $1 # @ cycle 11 r2 = -64 = 0xffffffc0
or $2, $1, $2 # @ cycle 12 r2 = -30 = 0xffffffe2
nor $2, $2, $1 # @ cycle 13 r2 = 29 = 0x1d
slt $2, $2, $1 # @ cycle 14 r2 = 0 = 0x0
slt $2, $1, $2 # @ cycle 15 r2 = 1 = 0x1
sll $2, $2, 1 # @ cycle 16 r2 = 2 = 0x2
srl $2, $2, 1 # @ cycle 17 r2 = 1 = 0x1
sra $2, $1, 3 # @ cycle 18 r2 = -4 = 0xfffffffc
jr $2 # @ cycle 20 PC = 0xfffffffc
nop
nop
nop
nop
nop
