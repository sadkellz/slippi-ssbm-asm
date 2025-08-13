################################################################################
# Address: 0x80224eac
################################################################################

.include "Common/Common.s"

.set REG_SLOT, 31
.set REG_POS, 30

.set P4_POINT, 0xC7
.set P5_POINT, 0xC8

CODE_START:

  cmpwi REG_SLOT, 4
  beq GET_SLOT4_POS
  cmpwi REG_SLOT, 5
  beq GET_SLOT5_POS
  b EXIT

  GET_SLOT4_POS:
    li REG_SLOT, P4_POINT
    b EXIT

  GET_SLOT5_POS:
    li REG_SLOT, P5_POINT
    b EXIT


EXIT:
  branchl r12, 0x80224fac
