################################################################################
# Address: 0x804a3120
# r3 = string
################################################################################

.include "Common/Common.s"

# copied out of objdiff

mflr r0
lis r4, 0x8047
stw r0, 0x4(r1)
crclr 6
subi r4, r4, 0x24a0
stwu r1, -0x8(r1)
branchl r12, OSReport
lwz r0, 0xc(r1)
addi r1, r1, 0x8
mtlr r0
blr
