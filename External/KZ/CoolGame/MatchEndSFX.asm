################################################################################
# Address: 0x802f7044
################################################################################

.include "Common/Common.s"
.include "KZ/PLAYER.s"

.set REG_COUNT, 20

# og
mr	r31, r3

CODE_START:
  backup

  li r3, 321
  li r4, 127
  li r5, 64
  branchl r12, 0x800237a8

  li r3, 329
  li r4, 127
  li r5, 64
  branchl r12, 0x800237a8

  # li r3, 0x19
  # addi r3, r3, 5
  # mulli r3, r3, 10000

  # li r4, 127
  # li r5, 64
  # branchl r12, 0x800237a8

EXIT:
  restore